[![Gem Version](https://badge.fury.io/rb/debt_ceiling.svg)](http://badge.fury.io/rb/debt_ceiling)
[![Build Status](https://travis-ci.org/bglusman/debt_ceiling.svg?branch=master)](https://travis-ci.org/bglusman/debt_ceiling)
[![Debt Ceiling Chat](https://badges.gitter.im/Join Chat.svg)](https://gitter.im/bglusman/debt_ceiling)
[![debt_ceiling API Documentation](https://www.omniref.com/ruby/gems/debt_ceiling.png)](https://www.omniref.com/ruby/gems/debt_ceiling)
[![Code Climate](https://codeclimate.com/github/bglusman/debt_ceiling/badges/gpa.svg)](https://codeclimate.com/github/bglusman/debt_ceiling)
#DebtCeiling

Main goal is to enforce a technical debt ceiling and tech debt reduction deadlines for your Ruby project programmatically via a configurable combination of static analysis and/or manual assignment/recognition from explicit source code references as part of your application's test suite.  Eventually perhaps will aid in visualizing this quantification as a graph or graphs, and breaking down debt into various categories and sources.  Currently it highlights the single largest source of debt as a suggestion for reduction, as well out outputting the total quantity, both in test suite integration or by manually running `debt_ceiling` binary.

Travis tests are running on 1.9.3, 2.1.1 and JRuby 1.9 mode.

Current features include:
* configuring points per [RubyCritic](https://github.com/whitesmith/rubycritic) grade per file line (add FULL_ANALYSIS=true for a lengthier analysis by RubyCritic including churn and more code smells, but same grading logic, made available for use by hooks)
* Comment added explicit/manual debt assignment, via #TECH DEBT +100 or custom phrases
* Whitelisting/blacklisting files by matching path/filename
* Modifying or replacing default calculation on a per file basis
* Reporting the single greatest source of debt based on your definitions
* Reporting total debt for the git repo based on your definitions
* Adding cost for TODOs or deprecated references you specify (see .debt_ceiling.example)
* Running from a test suite to fail if debt ceiling is exceeded
* Running from a test suite to fail if debt deadline is missed (currently only supports a single deadline, could add support for multiple targets if there's interest)

To integrate in a test suite, set a value for `debt_ceiling` and/or `reduction_target` and `reduction_date` in your configuration and call `DebtCeiling.calculate(root_dir)` from your test helper as an additional test.  It will exit with a non-zero failure if you exceed your ceiling or miss your target, failing the test suite.

These features are largely are demonstrated/discussed in [examples/.debt_ceiling.rb.example](https://github.com/bglusman/debt_ceiling/blob/master/examples/.debt_ceiling.rb.example) which demonstrates configuring debt ceiling

Additional customization is supported via two method hooks in the debt class, which debt_ceiling will load from a provided extension_file_path in the main config file, which should look like the [example file](https://github.com/bglusman/debt_ceiling/blob/master/examples/debt.rb.example)

You can configure/customize the debt calculated using a few simple commands in a .debt_ceiling.rb file in the project's home directory:

```
DebtCeiling.configure do |c|
  #exceeding this will fail a test, if you run debt_ceiling binary/calculate method from test suite
  c.debt_ceiling = 500
  #exceeding this target will fail after the reduction date (parsed by Chronic)
  c.reduction_target = 100
  c.reduction_date   = 'Jan 1 2015'
  #set the multipliers per line of code in a file with each letter grade, these are the current defaults
  c.grade_points = { a: 0, b: 10, c: 20, d: 40, f: 100 }
  #load custom debt calculations (see examples/debt.rb) from this path
  c.extension_path = "./debt.rb"
  #below two both use same mechanic, todo just assumes capital TODO as string, cost_per_todo defaults to 0
  c.cost_per_todo  = 50
  c.deprecated_reference_pairs = { 'DEPRECATED_API' => 20}
  #manually assign debt to code sections with these or with default "TECH DEBT", as a comment like #TECH DEBT +50
  c.manual_callouts += ["REFACTOR THIS", "HORRIBLE HACK"]
  #only count debt scores for files/folders matching these strings (converted to regexes)
  c.whitelist = %w(app lib)
  #or
  #exclude debt scores for files/folders matching these strings (commented as mutually exclusive)
  #c.blacklist = %w(config version debt_ceiling.rb)
end
```

As mentioned/linked above, additional customization is supported.

As shown in example file, set a path for `extension_path` pointing to a file defining DebtCeiling::Debt like the one in examples directory, and define its methods for your own additional calculation per file.

### Improvement ideas/suggestsions for contributing:

* rubocop/cane integration debt for style violations

* default/custom points per reek smell detected (not currently part of rubycritic grading, despite integration)

* every line over x ideal file size is y points of debt

* multipliers for important files

* command line options to configure options per run/without a .debt_ceiling file (could be done with [ENVied](https://github.com/eval/envied) gem perhaps, or [commander](https://github.com/tj/commander) or [one of these](https://www.ruby-toolbox.com/categories/CLI_Option_Parsers)

* visualization/history of debt would be nice, but unclear how to best support...  one possibility is running it against each commit in a repo, and using git-notes to add score data (and some metadata perhaps?) to store it for comparing/graphing, and for comparing branches etc. optionally configured could do this for every commit that doesn't already have a note attached, or for which the note's metadata/version is out of sync with current definitions.

* optionally include/integrate with one of these JS analysis libraries, or another if anyone had another suggestion: [plato](https://github.com/es-analysis/plato) [jsprime](https://github.com/dpnishant/jsprime) [doctorjs](https://github.com/mozilla/doctorjs)

## License

`debt_ceiling` is MIT licensed. [See the accompanying file](MIT-LICENSE.md) for
the full text.
