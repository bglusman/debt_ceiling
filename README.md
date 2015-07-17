[![Gem Version](https://badge.fury.io/rb/debt_ceiling.svg)](http://badge.fury.io/rb/debt_ceiling)
[![Build Status](https://travis-ci.org/bglusman/debt_ceiling.svg?branch=master)](https://travis-ci.org/bglusman/debt_ceiling)
[![Coverage Status](https://img.shields.io/coveralls/bglusman/debt_ceiling.svg)](https://coveralls.io/r/bglusman/debt_ceiling?branch=master)
[![Debt Ceiling Chat](https://badges.gitter.im/Join Chat.svg)](https://gitter.im/bglusman/debt_ceiling)
[![Stories in Ready](https://badge.waffle.io/bglusman/debt_ceiling.png?label=ready&title=Ready)](https://waffle.io/bglusman/debt_ceiling)
[![Code Climate](https://codeclimate.com/github/bglusman/debt_ceiling/badges/gpa.svg)](https://codeclimate.com/github/bglusman/debt_ceiling)
#DebtCeiling

Main goal is to enforce a technical debt ceiling and tech debt reduction deadlines for your Ruby project programmatically via a configurable combination of static analysis and/or manual assignment/recognition from explicit source code references as part of your application's test suite.  Eventually perhaps will aid in visualizing this quantification as a graph or graphs, and breaking down debt into various categories and sources.  Currently it highlights the single largest source of debt as a suggestion for reduction, as well out outputting the total quantity, both in test suite integration or by manually running `debt_ceiling` binary.

Travis tests are running on 1.9.3, 2.1.1, Rubinius 2.2 and JRuby 1.9 mode.

Current features include:
* configuring points per [RubyCritic](https://github.com/whitesmith/rubycritic) grade per file
* configuring multipliers for specific static analysis attributes, including complexity, duplication, method count, reek smells
* configuring ideal max lines per file/module, and a per line penalty for each additional line
* configuing a max debt per file/module, exceeding which will fail tests
* Comment added explicit/manual debt assignment, via `#TECH DEBT +100` or custom word/phrase
* Whitelisting/blacklisting files by matching path/filename
* Modifying or replacing default calculation on a per file basis
* Reporting the single greatest source of debt based on your definitions
* Reporting total debt for the git repo based on your definitions
* Adding cost for TODOs or deprecated references you specify (see [.debt_ceiling.rb.example](https://github.com/bglusman/debt_ceiling/blob/master/examples/.debt_ceiling.rb.example))
* Running from a test suite to fail if debt ceiling is exceeded
* Running from a test suite to fail if debt deadline is missed (currently only supports a single deadline, could add support for multiple targets if there's interest)

To integrate in a test suite, set a value for `debt_ceiling`, `max_debt_per_module` and/or `reduction_target` and `reduction_date` in your configuration and call `DebtCeiling.audit` from your test helper as an additional test, or drop the call and/or configuration directly in your spec helper:
```ruby
  require 'debt_ceiling'
  config.after(:all) do
    DebtCeiling.configure do |c|
      c.whitelist = %w(app lib)
      c.max_debt_per_module = 150
      c.debt_ceiling = 250
    end
    DebtCeiling.audit(preconfigured: true)
  end
```
`audit` defaults to '.' as root directory, since specs are usually run from root, but you can pass it a relative path as an argument, i.e. `DebtCeiling.audit('./lib')`

It will exit with a non-zero failure, failing the test suite, if you exceed your ceiling(s) or miss your target and print the failure and reason for failure.  If you wish debt ceiling to run and print the failures, but not fail the test suite when thresholds are exceeded or targets are missed, call the audit method with the `warn_only` option, i.e.: `DebtCeiling.audit(warn_only: true)`

These features are largely demonstrated/discussed in [examples/.debt_ceiling.rb.example](https://github.com/bglusman/debt_ceiling/blob/master/examples/.debt_ceiling.rb.example) or below snippet which demonstrates configuring debt ceiling around a team or maintainer's agreed ideas about how to quantify debt automatically and/or manually in the project source code.

Additional customization is supported via two method hooks in the debt class, which DebtCeiling will load from a provided extension_path in the main config file, which should look like the [example file](https://github.com/bglusman/debt_ceiling/blob/master/examples/custom_debt.rb.example)

You can configure/customize the debt calculated using a few simple commands in a .debt_ceiling.rb file in the project's home directory:

```ruby
DebtCeiling.configure do |c|
  #exceeding this will fail a test, if you run debt_ceiling binary/calculate method from test suite
  c.debt_ceiling = 250
  #exceeding this target will fail after the reduction date (parsed by Chronic)
  c.reduction_target = 100
  c.reduction_date   = 'Jan 1 2016'
  #set the multipliers per line of code in a file with each letter grade, these are the current defaults
  c.grade_points = { a: 0, b: 10, c: 20, d: 40, f: 100 }
  #load custom debt calculations (see examples/custom_debt.rb) from this path
  c.extension_path = "./custom_debt.rb"
  #below two both use same mechanic, todo just assumes capital TODO as string, cost_per_todo defaults to 0
  c.cost_per_todo  = 50
  c.deprecated_reference_pairs = { 'DEPRECATED_API' => 20}
  #manually assign debt to code sections with these or with default "TECH DEBT", as a comment like #TECH DEBT +50
  c.manual_callouts += ["REFACTOR THIS", "HORRIBLE HACK"]
  #only count debt scores for files/folders matching these strings (converted to regexes)
  c.whitelist = %w(app lib)
  #or
  #exclude debt scores for files/folders matching these strings (commented as mutually exclusive)
  #c.blacklist = %w(config schema routes)
end
```

As mentioned/linked above, additional customization is supported via a custom_debt.rb file which may define one or both of two methods DebtCeiling will call if defined when calculating debt for each module scanned (if it passes the whitelist/blacklist stage of filtering).

As shown in example file, set a path for `extension_path` pointing to a file defining `DebtCeiling::CustomDebt` like the one in examples directory, and define its methods for your own additional calculation per file.

### Improvement ideas/suggestsions for contributing:

* rubocop/cane integration debt for style violations

* multipliers for important files

* command line options to configure options per run/without a `.debt_ceiling.rb` file (could be done with [ENVied](https://github.com/eval/envied) gem perhaps, or [commander](https://github.com/tj/commander) or [one of these](https://www.ruby-toolbox.com/categories/CLI_Option_Parsers)

* visualization/history of debt would be nice, but unclear how to best support...  one possibility is running it against each commit in a repo, and using git-notes to add score data (and some metadata perhaps?) to store it for comparing/graphing, and for comparing branches etc. optionally configured could do this for every commit that doesn't already have a note attached, or for which the note's metadata/version is out of sync with current definitions.

* optionally include/integrate with one of these JS analysis libraries, or another if anyone had another suggestion: [plato](https://github.com/es-analysis/plato) [jsprime](https://github.com/dpnishant/jsprime) [doctorjs](https://github.com/mozilla/doctorjs)  Could also create a plugin architecture and do JS that way, and allow any other language to add plugin handling so it could be a multi-language standard tool.

## License

`debt_ceiling` is MIT licensed. [See the accompanying file](MIT-LICENSE.md) for
the full text.
