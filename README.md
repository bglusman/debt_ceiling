#DebtCeiling
[![Gitter](https://badges.gitter.im/Join Chat.svg)](https://gitter.im/bglusman/debt_ceiling?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

###
Work in progress, trying to use some automatic heuristic plus manual mechanisms to help visibility and tracking of technical debt.

Current plan is to configure/customize the weight given to heuristic grade
based first on a simple DSL in a .debt_ceiling file in the project's home directory, and if additional customization is desired, pass a path to 
`extension_file_path` command in the DSL file to a file defining DebtCeiling::Debt like the one in examples directory, and replace/augment it's methods with your own additional calculation per file.
