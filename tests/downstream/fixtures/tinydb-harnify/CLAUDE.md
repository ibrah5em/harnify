@AGENTS.md

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

TinyDB: a small, pure-Python, document-oriented database with no runtime dependencies. Python >=3.10, CPython and PyPy. Trunk is `master`.

## Commands

The tooling is uv with a `dev` dependency group. These commands come from `.github/workflows/ci-workflow.yml`:

```sh
uv sync --group dev                         # install dev deps
uv run pytest                               # full suite; pytest.ini adds --cov tinydb and -v
uv run pytest tests/test_queries.py::test_eq   # single test
uv run pytest -k upsert                     # by keyword
uv run pytest --mypy -m mypy tinydb tests   # type check (CI runs this on 3.14 only)
uv build && uv run --with twine twine check dist/*   # verify dist package
cd docs && make html                        # Sphinx docs
```

- `pytest.ini` always adds `--cov-append`, so stale `.coverage` data carries over between runs. Delete `.coverage` if you need clean numbers.
- mypy loads `tinydb/mypy_plugin.py` (configured in `mypy.ini`). This makes `mypy` importable at type-check time, but it is not a runtime dependency.
- Style is PEP 8, checked with pycodestyle (`pytest-pycodestyle` is in the dev group, though CI doesn't run it). Multi-line docstrings keep `"""` on their own lines, followed by a blank line before the code (see `CONTRIBUTING.rst`).

## Architecture

The layers, from top to bottom:

`TinyDB` (`database.py`) → `Table` (`table.py`) → `Storage`, optionally wrapped by a `Middleware` (`storages.py`, `middlewares.py`)

- **`TinyDB`** builds a storage instance from `storage=` (default `JSONStorage`). All other args/kwargs go to the storage constructor. It caches `Table` objects by name. It forwards any unknown attribute to the `_default` table through `__getattr__`, which is why `db.insert(...)` works. It inherits from `with_typehint(Table)`, which is `Table` only under `TYPE_CHECKING` and `object` at runtime. Pyright understands this pattern on its own, but mypy needs `mypy_plugin.py`. Don't remove the plugin.
- **The storage contract** is read/write of the *entire* database as `{table_name: {doc_id_str: document}}`. There are no partial writes: every mutation goes through `Table._update_table`, which reads everything, converts IDs to `document_id_class`, applies an updater closure, converts IDs back to `str` (because JSON keys are strings), writes everything, and clears the query cache. Doc IDs are always strings in storage and `int` (`document_id_class`) in the API.
- **Next IDs** come from `Table._next_id`, an in-memory counter seeded from `max(id)+1`. If you change how docs are inserted or removed, keep that counter consistent.
- **Query cache**: `Table.search` caches results in an `LRUCache` keyed by the query object. Queries must therefore hash stably. `QueryInstance` carries a `hashval` tuple. If that tuple is `None` or unhashable, the query is uncacheable (for example `Query.test` with mutable args, or `.map()`). `utils.freeze` turns lists/dicts into hashable forms for hashvals. A new query method must build a correct hashval, or it breaks caching or makes distinct queries collide. Cached result documents are shared objects, not copies.
- **`Query`** (`queries.py`) is a builder. Attribute and item access extend `_path`. Comparison operators and methods call `_generate_test`, which returns a `QueryInstance` (combinable with `&`, `|`, `~`). Any missing path or `TypeError` makes the test evaluate to False. Adding a `Query` method shadows document fields with that name under attribute syntax (`Query().newname`). The changelog treats this as a potential break even in a feature release, so call it out.
- **Middlewares** wrap a storage *class*: `CachingMiddleware(JSONStorage)` is passed as `storage=`. Calling it instantiates the inner storage, and unknown attributes are proxied to it. `CachingMiddleware` buffers writes until `flush()`/`close()` or until `WRITE_CACHE_SIZE` is reached.
- **`operations.py`** functions return `doc -> None` mutators that `Table.update` accepts in place of a dict.
- **Extension points** are the class attributes on `TinyDB` (`table_class`, `default_table_name`, `default_storage_class`) and on `Table` (`document_class`, `document_id_class`, `query_cache_class`, `default_query_cache_capacity`). These are public API.

## Tests

`tests/conftest.py`'s `db` fixture is parametrized over `memory` and `json` storages, so most table and database tests run twice. A behavior that only breaks with string-keyed JSON round-tripping will show up only in the `json` variant.

## Project conventions

- SemVer. Public API breaks require a major version bump.
- User-visible changes get an entry in `docs/changelog.rst`.
- `docs/extensions.rst` lists third-party extensions. The criteria for staying on the list are at the top of that file.
- `CONTRIBUTING.rst` requires a test proving each fix or feature. It also asks that issue and PR text and review replies be written by the contributor, not pasted from generated output.
