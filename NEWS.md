# interfacer 0.2.1

* Added a `NEWS.md` file to track changes to the package.
* Initial CRAN submission.

# interfacer 0.2.2

* Fixed `README.md` URL issue and DESCRIPTION typo.
* automated spell test

# interfacer 0.2.3

* This is a resubmission to fix issues identified in CRAN submission v0.2.2: 1) 
additional spaces in DESCRIPTION file. 2) functions missing return values. 3) 
example containing unexported method. 4) `if (FALSE)` stanza in examples for 
function that can only be used interactively.

# interfacer 0.2.4

* Minor enhancement of type coercion to support more consistent behaviour for
finding custom `type.XX` functions in downstream packages.
* Funding statement added to README.

# interfacer 0.3.0

* Consistency checking and recycling for non-dataframe parameters API added, 
with new vignette to explain.
* More consistent `type.XX` function behaviour.

# interfacer 0.3.1

* Documentation tidy-up.
* Minor change to formatting of `iface` printing.

# interfacer 0.3.2

* Specific support for `unique_id` columns (ids unique between dataframe grouping).
* Fix issue with `imapper` defaults always being applied.

# interfacer 0.3.3

* performance issue fix
* move repository to `ai4ci`

# interfacer 0.3.4

* allow renaming or preprocessing of variable names in `igroup_process` and use
of `.groupdata` parameter in dispatch function. 
* `@ireturn` `roxygen2` tag for automatically picking up format from `ireturn(df,spec)`
(n.b. this will hit the first detected value, not all of them).

# interfacer 0.3.5

* improved behaviour of `@iparam` when `idispatch` is used. 
* `ireturn` validation disabled by default in deployment mode.
* validation does not strip dataframe attributes any more.

# interfacer 0.3.6

* speed-up via better function matching
* documentation of `@iparam` grouping accounts for `igroup_process` calls in 
function body

# interfacer 0.3.7

* experimental support for group processing by an externally supplied interface 
spec

# interfacer 0.4.0

* Change in `idispatch` to allow lazy evaluation in parameters and correct 
behaviour in the context of data-mask processing and defusal / quoted evaluation. 
* Some internal (but exported) demo testing functions added to allow more 
rigorous outside of package scope (e.g. `?demo_idispatch`)
* Much improved testing of `idispatch` using demo functions.
* No functional downstream impacts should be obvious unless anyone relying on 
eager evaluation in previous versions of `idispatch`

