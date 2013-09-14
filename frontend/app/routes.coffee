module.exports = (match) ->
  match '', 'home#index'
  match 'shared/:id', 'grandma#index'
  match 'test/:id', 'grandma#test'
  match '*url', 'notfound#index'
