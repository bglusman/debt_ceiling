DebtCeiling.configure do |c|
  #exceeding this will fail a test, if you run debt_ceiling binary/calculate method from test suite
  c.debt_ceiling = 500

  #only count debt scores for files/folders matching these strings (converted to regexes)
  c.debt_ceiling_per_module = 200
  c.cost_per_todo  = 50
  c.whitelist = %w(app lib)
end