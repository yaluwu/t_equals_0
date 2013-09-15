module.exports = (match) ->
  match '', 'home#index'
  match 'share/:id', 'grandma#index'
  match 'shared/:id', 'grandma#index'
  match 'test/:id', 'grandma#test'
  match 'sharing/:id/:recipient/:sender', 'sender#index'
  match 'sharing/:id/:recipient', 'sender#index'
  match '*url', 'notfound#index'
