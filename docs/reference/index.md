# Package index

## Interface specification

- [`iconvert()`](https://ai4ci.github.io/interfacer/reference/iconvert.md)
  : Convert a dataframe to a format compatible with an interface
  specification

- [`idispatch()`](https://ai4ci.github.io/interfacer/reference/idispatch.md)
  : Dispatch to a named function based on the characteristics of a
  dataframe

- [`iface()`](https://ai4ci.github.io/interfacer/reference/iface.md) :
  Construct an interface specification

- [`igroup_process()`](https://ai4ci.github.io/interfacer/reference/igroup_process.md)
  : Handle unexpected additional grouping structure

- [`imapper()`](https://ai4ci.github.io/interfacer/reference/imapper.md)
  :

  Specify mappings that can make dataframes compatible with an `iface`
  specification

- [`iproto()`](https://ai4ci.github.io/interfacer/reference/iproto.md) :

  Generate a zero length dataframe conforming to an `iface`
  specification

- [`ireturn()`](https://ai4ci.github.io/interfacer/reference/ireturn.md)
  : Validate and return a value from a function

- [`is.iface()`](https://ai4ci.github.io/interfacer/reference/is.iface.md)
  : Check if an object is an interface specification

- [`itest()`](https://ai4ci.github.io/interfacer/reference/itest.md) :
  Test dataframe conformance to an interface specification.

- [`ivalidate()`](https://ai4ci.github.io/interfacer/reference/ivalidate.md)
  : Perform interface checks on dataframe inputs using enclosing
  function formal parameter definitions

## Type coercion rules

- [`type.anything()`](https://ai4ci.github.io/interfacer/reference/type.anything.md)
  : Coerce to an unspecified type
- [`type.character()`](https://ai4ci.github.io/interfacer/reference/type.character.md)
  : Coerce to a character.
- [`type.complete()`](https://ai4ci.github.io/interfacer/reference/type.complete.md)
  : Coerce to a complete set of values.
- [`type.date()`](https://ai4ci.github.io/interfacer/reference/type.date.md)
  : Coerce to a Date.
- [`type.default()`](https://ai4ci.github.io/interfacer/reference/type.default.md)
  : Set a default value for a column
- [`type.double()`](https://ai4ci.github.io/interfacer/reference/type.double.md)
  : Coerce to a double.
- [`type.enum()`](https://ai4ci.github.io/interfacer/reference/type.enum.md)
  : Define a conformance rule to match a factor with specific levels.
- [`type.factor()`](https://ai4ci.github.io/interfacer/reference/type.factor.md)
  : Coerce to a factor.
- [`type.finite()`](https://ai4ci.github.io/interfacer/reference/type.finite.md)
  : Check for non-finite values
- [`type.group_unique()`](https://ai4ci.github.io/interfacer/reference/type.group_unique.md)
  : Coerce to a unique value within the current grouping structure.
- [`type.in_range()`](https://ai4ci.github.io/interfacer/reference/type.in_range.md)
  : Define a conformance rule to confirm that a numeric is in a set
  range
- [`type.integer()`](https://ai4ci.github.io/interfacer/reference/type.integer.md)
  : Coerce to integer
- [`type.logical()`](https://ai4ci.github.io/interfacer/reference/type.logical.md)
  : Coerce to a logical
- [`type.not_missing()`](https://ai4ci.github.io/interfacer/reference/type.not_missing.md)
  : Check for missing values
- [`type.numeric()`](https://ai4ci.github.io/interfacer/reference/type.numeric.md)
  : Coerce to a numeric.
- [`type.of_type()`](https://ai4ci.github.io/interfacer/reference/type.of_type.md)
  : Check for a given class
- [`type.positive_double()`](https://ai4ci.github.io/interfacer/reference/type.positive_double.md)
  : Coerce to a positive double.
- [`type.positive_integer()`](https://ai4ci.github.io/interfacer/reference/type.positive_integer.md)
  : Coerce to a positive integer.
- [`type.proportion()`](https://ai4ci.github.io/interfacer/reference/type.proportion.md)
  : Coerce to a number between 0 and 1
- [`type.unique_id()`](https://ai4ci.github.io/interfacer/reference/type.unique_id.md)
  : A globally unique ids.

## Parameter consistency checks

- [`check_character()`](https://ai4ci.github.io/interfacer/reference/check_character.md)
  : Checks a set of variables can be coerced to a character and coerces
  them
- [`check_consistent()`](https://ai4ci.github.io/interfacer/reference/check_consistent.md)
  : Check function parameters conform to a set of rules
- [`check_date()`](https://ai4ci.github.io/interfacer/reference/check_date.md)
  : Checks a set of variables can be coerced to a date and coerces them
- [`check_integer()`](https://ai4ci.github.io/interfacer/reference/check_integer.md)
  : Checks a set of variables can be coerced to integer and coerces them
- [`check_logical()`](https://ai4ci.github.io/interfacer/reference/check_logical.md)
  : Checks a set of variables can be coerced to a logical and coerces
  them
- [`check_numeric()`](https://ai4ci.github.io/interfacer/reference/check_numeric.md)
  : Checks a set of variables can be coerced to numeric and coerces them
- [`check_single()`](https://ai4ci.github.io/interfacer/reference/check_single.md)
  : Checks a set of variables are all of length one
- [`recycle()`](https://ai4ci.github.io/interfacer/reference/recycle.md)
  : Strictly recycle function parameters
- [`resolve_missing()`](https://ai4ci.github.io/interfacer/reference/resolve_missing.md)
  : Resolve missing values in function parameters and check consistency

## roxygen2 documentation

- [`iclip()`](https://ai4ci.github.io/interfacer/reference/iclip.md) :

  Create an `iface` specification from an example dataframe

- [`idocument()`](https://ai4ci.github.io/interfacer/reference/idocument.md)
  :

  Document an interface contract for inserting into `roxygen2`

- [`roxy_tag_parse(`*`<roxy_tag_iparam>`*`)`](https://ai4ci.github.io/interfacer/reference/roxy_tag_parse.roxy_tag_iparam.md)
  :

  Parser for `@iparam` tags

- [`roxy_tag_parse(`*`<roxy_tag_ireturn>`*`)`](https://ai4ci.github.io/interfacer/reference/roxy_tag_parse.roxy_tag_ireturn.md)
  :

  Parser for `@ireturn` tags

- [`roxy_tag_rd(`*`<roxy_tag_iparam>`*`)`](https://ai4ci.github.io/interfacer/reference/roxy_tag_rd.roxy_tag_iparam.md)
  :

  Support for `@iparam` tags

- [`roxy_tag_rd(`*`<roxy_tag_ireturn>`*`)`](https://ai4ci.github.io/interfacer/reference/roxy_tag_rd.roxy_tag_ireturn.md)
  :

  Support for `@ireturn` tags

- [`use_dataframe()`](https://ai4ci.github.io/interfacer/reference/use_dataframe.md)
  : Use a dataframe in a package including structure based documentation

- [`use_iface()`](https://ai4ci.github.io/interfacer/reference/use_iface.md)
  : Generate interfacer code for a dataframe

## Others

- [`as.list(`*`<iface>`*`)`](https://ai4ci.github.io/interfacer/reference/as.list.iface.md)
  :

  Cast an `iface` to a plain list.

- [`format(`*`<iface>`*`)`](https://ai4ci.github.io/interfacer/reference/format.iface.md)
  :

  Format an `iface` specification for printing

- [`get_iface()`](https://ai4ci.github.io/interfacer/reference/get_iface.md)
  :

  Extract the `interfacer` specification for a function

- [`if_col_present()`](https://ai4ci.github.io/interfacer/reference/if_col_present.md)
  : Execute a function or return a value if a column in present in a
  dataframe

- [`imissing()`](https://ai4ci.github.io/interfacer/reference/imissing.md)
  :

  Test if an `iface` parameter was supplied to a function

- [`is_col_present()`](https://ai4ci.github.io/interfacer/reference/is_col_present.md)
  : Check for existence of a set of columns in a dataframe

- [`knit_print.iface()`](https://ai4ci.github.io/interfacer/reference/knit_print.iface.md)
  :

  Format an `iface` specification for printing

- [`print(`*`<iface>`*`)`](https://ai4ci.github.io/interfacer/reference/print.iface.md)
  :

  Format an `iface` specification for printing

- [`switch_pipeline()`](https://ai4ci.github.io/interfacer/reference/switch_pipeline.md)
  :

  Branch a `dplyr` pipeline based on a set of conditions
