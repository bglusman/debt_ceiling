DebtCeiling.configure do |c|
  c.whitelist = %w(bin lib)
  c.max_debt_per_module = 100
  c.debt_ceiling = 500
end
