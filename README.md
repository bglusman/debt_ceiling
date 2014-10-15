[![Debt Ceiling Chat](https://badges.gitter.im/Join Chat.svg)](https://gitter.im/bglusman/debt_ceiling)

#DebtCeiling

### Work in progress, feedback and PR's appreciated

Current features include:
* configuring points per [RubyCritic](https://github.com/whitesmith/rubycritic) grade per file line
* Whitelisting/blacklisting files by matching path/filename
* Modifying or replacing default calculation on a per file basis
* Reporting the single greatest source of debt based on your definitions
* Reporting total debt for the git repo based on your definitions
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

## TODO: planned features/ideas

todo_cost 500      #cost per comment matching /TODO/

debt_per_reference_to deprecated_regex, 500 # help transition away from deprecated APIs 

points_per_regex_match REGEX, 500 # seems like an alias for above maybe, nix?


### Other ideas:

rubocop/cane integration debt for style violations

every line over x ideal file size is y points of debt

multipliers for important files

include one of the JS complexity/debt analysis libraries below, or another if anyone had another suggestion: 

* https://github.com/es-analysis/plato

* https://github.com/dpnishant/jsprime

* https://github.com/mozilla/doctorjs