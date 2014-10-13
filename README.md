[![Debt Ceiling Chat](https://badges.gitter.im/Join Chat.svg)](https://gitter.im/bglusman/debt_ceiling)

#DebtCeiling


### Work in progress, trying to use some automatic heuristic plus manual mechanisms to help visibility and tracking of technical debt.

Current features include:
* configuring points per [RubyCritic](https://github.com/whitesmith/rubycritic) grade per file line
* Whitelisting/blacklisting files by filename
* Modifying or replacing default calculation on a per file basis
* Reporting the single greatest source of debt based on your definitions
* Reporting total debt for the git repo based on your definitions

These features are largely are demonstrated/discussed in [examples/.debt_ceiling](https://github.com/bglusman/debt_ceiling/blob/master/examples/.debt_ceiling.example) which demonstrates a simple DSL for configuring debt ceiling, and additional customization is supported via two method hooks in the debt class, which debt_ceiling will load from a provided extension_file_path in the main config file, which should look like the [example file](https://github.com/bglusman/debt_ceiling/blob/master/examples/debt.rb.example)

Current plan is to configure/customize the weight given to heuristic grade
based first on a simple DSL in a .debt_ceiling file in the project's home directory, and if additional customization is desired, pass a path to 
`extension_file_path` command in the DSL file to a file defining DebtCeiling::Debt like the one in examples directory, and replace/augment it's methods with your own additional calculation per file.

Right now it badly needs tests, but I think the API etc needs fleshing out before worth writing.

## TODO: planned features/ideas

### unimplemented DSL plans:

These two will probably be main points of test suite integration:

debt_ceiling 15000 # integrate with test suite, pass below, fail above

debt_payment_deadline <parseable date>, <target ceiling at date>

More custom calculation from DSL:

todo_cost 500      #cost per comment matching /TODO/

debt_per_reference_to deprecated_regex, 500 # help transition away from deprecated APIs 

points_per_regex_match REGEX, 500 # seems like an alias for above maybe, nix?


### Other ideas:

rubocop/cane integration debt for style violations

every line over x ideal file size is y points of debt

multipliers for important files

include some kind of JS complexity/debt analysis optionally? 

https://github.com/es-analysis/plato
https://github.com/dpnishant/jsprime
https://github.com/mozilla/doctorjs