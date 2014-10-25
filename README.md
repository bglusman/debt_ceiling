[![Build Status](https://travis-ci.org/bglusman/debt_ceiling.svg?branch=master)](https://travis-ci.org/bglusman/debt_ceiling)[![Debt Ceiling Chat](https://badges.gitter.im/Join Chat.svg)](https://gitter.im/bglusman/debt_ceiling) [![debt_ceiling API Documentation](https://www.omniref.com/ruby/gems/debt_ceiling.png)](https://www.omniref.com/ruby/gems/debt_ceiling)

#DebtCeiling

Main goal is to enforce a technical debt ceiling and tech debt reduction deadlines for your Ruby project programmatically via a configurable combination of static analysis and/or manual assignment/recognition from explicit source code references as part of your application's test suite.  Eventually perhaps will aid in visualizing this quantification as a graph or graphs, and breaking down debt into various categories and sources.  Currently it highlights the single largest source of debt as a suggestion for reduction, as well out outputting the total quantity, both in test suite interation or by manually running `debt_ceiling` binary.

Current features include:
* configuring points per [RubyCritic](https://github.com/whitesmith/rubycritic) grade per file line (add FULL_ANALYSIS=true for a lengthier analysis by RubyCritic including churn and more code smells, but same grading logic, made available for use by hooks)
* Comment added explicit/manual debt assignment, via #TECH DEBT +100 or custom phrases
* Whitelisting/blacklisting files by matching path/filename
* Modifying or replacing default calculation on a per file basis
* Reporting the single greatest source of debt based on your definitions
* Reporting total debt for the git repo based on your definitions
* Adding cost for TODOs or deprecated references you specify (see .debt_ceiling.example)
* Running the binary from a test suite to fail if debt ceiling is exceeded
* Running the binary from a test suite to fail if debt deadline is missed

To integrate in a test suite, use `set_debt_ceiling` and/or `debt_reduction_target_and_date` in your configuration and call `DebtCeiling.calculate(root_dir)` from your test helper as an additional test.  It will exit with a non-zero failure if you exceed your ceiling or miss your target, failing the test suite.

These features are largely are demonstrated/discussed in [examples/.debt_ceiling](https://github.com/bglusman/debt_ceiling/blob/master/examples/.debt_ceiling.example) which demonstrates configuring debt ceiling

Additional customization is supported via two method hooks in the debt class, which debt_ceiling will load from a provided extension_file_path in the main config file, which should look like the [example file](https://github.com/bglusman/debt_ceiling/blob/master/examples/debt.rb.example)

You can configure/customize the debt calculated using a few simple commands in a .debt_ceiling file in the project's home directory

```
set_debt_ceiling 500
#exceeding this will fail a test, if you run debt_ceiling binary from test suite
debt_reduction_target_and_date 100, 'Jan 1 2015'
#exceeding this will fail after the target date (parsed by Chronic)

#set the multipliers per line of code in a file with each letter grade
b_cost_per_line 10
c_cost_per_line 20
d_cost_per_line 40
f_cost_per_line 100

#load custom debt calculations (see examples/debt.rb) from this path
extension_file_path "./debt.rb"

#only count debt scores for files matching these strings (converted to regexes)
whitelist_matching %w(app lib)

#or.... exclude debt scores for files matching these strings (obviously mutually exclusive, raises error if both present)
#blacklist_matching %w(schema.rb routes.rb)
```

As mentioned/linked above, additional customization is supported.

As shown in example file, pass a path to `extension_file_path` command pointing to a file defining DebtCeiling::Debt like the one in examples directory, and define its methods for your own additional calculation per file.

Right now it lacks all tests...  feel free to open a PR!

I'll try and add test coverage where it makes sense as API matures.

### Improvement ideas:

rubocop/cane integration debt for style violations

default/custom points per reek smell detected (not currently part of rubycritic grading, despite integration)

every line over x ideal file size is y points of debt

multipliers for important files

command line options to configure options per run/without a .debt_ceiling file

visualization/history of debt would be nice, but unclear how to best support...  one possibility is running it against each commit in a repo, and using git-notes to add score data (and some metadata perhaps?) to store it for comparing/graphing, and for comparing branches etc. optionally configured could do this for every commit that doesn't already have a note attached, or for which the note's metadata/version is out of sync with current definitions.

include one of the JS complexity/debt analysis libraries below, or another if anyone had another suggestion:

* https://github.com/es-analysis/plato

* https://github.com/dpnishant/jsprime

* https://github.com/mozilla/doctorjs
