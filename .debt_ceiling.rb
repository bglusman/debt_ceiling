DebtCeiling.configure do |c|
  c.whitelist = %w(bin lib)
  c.max_debt_per_module = 150
  c.debt_ceiling = 300
end
