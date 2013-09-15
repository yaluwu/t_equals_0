template = require 'views/templates/grandma'
View = require 'views/base/view'

module.exports = class GrandmaPageView extends View
  autoRender: yes
  className: 'home-page'
  container: '#page-container'
  template: template

  initialize: (params) ->
    @modelx = params.modelx
    super

    {id, test} = @modelx
    userType = if test then 'sender' else 'grandma'

    @socket = io.connect()

    @socket.on 'serverReply', (data) =>
      setTimeout (=>
        @socket.emit 'iamUser', {userType, id}
      ), 1000

    @socket.on 'fileNew', _.bind @fileNew, @
    @socket.on 'fileChunk', _.bind @fileChunk, @
    @socket.on 'fileClose', _.bind @fileClose, @
    @socket.on 'error', _.bind @error, @

    @currentFile =
      type: ''
      length: ''
      content: ''
      sender: 
        name: ''
        email: ''
      closed: false
      
    @chunks = []

    window.view = @

    @socket.emit 'canIHazFile'

  error: ->
    console.log 'error :('
    # ['fileNew', 'fileChunk', 'fileClose', 'error'] (from sender)
    # 'canIHazFile' (to sender)

  fileNew: (data) ->
    console.log data
    @currentFile.type = data.type
    @currentFile.length = data.size
    @currentFile.sender = data.sender
    @currentFile.content = ''
    @chunks = []

  fileChunk: (data) ->
    @chunks.push(data)

  fileClose: (data) ->
    console.log "file transfer finished"
    @currentFile.content = @chunks.join('')
    @currentFile.closed = true
    @render()

  render: ->
    type = if @currentFile.closed then @currentFile.type else ''

    switch 
      when type.search(/^image/) > -1
        content =  img: @currentFile
      when type.search(/^plain/) > -1
        content = text: @currentFile
      when type.search(/youtube/) > -1
        console.log "epic"
        content = video: @currentFile
      else
        content = undefined

    @$el.html(@template({content}))

  sendChunk: (chunk) ->
    @socket.emit "fileChunk", chunk

  sendDataz: (meta, data) ->
    console.log "beginning file transfer..."
    @socket.emit "fileNew", meta

    console.log "chunking file..."
    @sendChunk chunk for chunk in data
    console.log "finishing transfer..."
    @socket.emit "fileClose"
    console.log "done"

  sendVideo: (url = 'g85wBkhFhjo') ->
    data = [url]

    meta = 
      type: "video/youtube"
      length: 0
      sender:
        name: "Yalu Wu"
        email: "yaluwu@gmail.com"
        
    @sendDataz meta, data
    
  sendText: () ->
    data = [
      'Hey grandma! How are you doing?  I hope you are enjoying this '
      'wonderful weather we\'ve been having.  I miss you tons and wish '
      'you could be here.  Maybe we can go visit in November?\n\n'
      'Love,\nMike'
    ]

    meta = 
      type: "plain/text"
      length: 0
      sender:
        name: "Mike Axiak"
        email: "mcaxiak@gmail.com"
        
    @sendDataz meta, data

  sendImage: () ->
    data = [
      'iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAIAAABMXPacAAAACX'
      'BIWXMAAA7DAAAOwwHHb6hkAAAA\nB3RJTUUH3QkOFgUXabQeUwA'
      'ADxVJREFUeNrtnXl8VNXZx8+5y+xhMlknCQkJkIQYQCkUVBYLb'
      '5Ei\n4oZFEbSIH9RYBFMUKQULRQReCShEQJEqvIiCC6AEFAUMmr'
      'cuaVCIkED2PTPJJDPJbHc5p39EU0oz\nd+5Mtklyfp/8lVnund/'
      '3LM85997ngRhjQNR7oogFBAABQNR7YgL2zKpclfXu2nquttxZ1'
      'sw3WfhG\nEYs2wepGbggBj/gmvgkCgAEOVYRRgAYAAIAjFEYIYY'
      'TCGMKGRCqNMarYaGVMpMIIYYA2NRggk7CA\nBQ5xzUJTjiX7rOX'
      'zUkcxDRkKUhSgKH+9QxghgBBGGOAUXeqUkGkTg6eoabWSUtGQJ'
      'gB+1nlb7heN\nn1Y5K5qEJivfDACgIAUB7NqjYIARFjHAwYwhRB'
      'EWr06YEXZnii51gAJwIWe9u+6rpi8/rv+wVWxV\nUsoud9xL5wC'
      'IQ1woGzojfPZEw+RIRZSG1gwIAK1iy66K7Rds552iQwRiD/veY'
      'c+gIa2mNKMG3fRE\n7NN6Rt9vAVxs+eGk+ZPTjadUgTQEt0vEoo'
      'jF20KmzQy/a2TQ6H4FINf6bWZ5hk2w9ZXQUMfo0uNX\njhk0rs8'
      'DONWQ9VHd4UpXhYJS9Ppo49O4xCEuUZt8X+QDU0Km9j0AGOA6V'
      '+2LJWuqnZVU1wXgGMg6\n1S4kzWM+Vj1k9dD1UarobmpAXQ/AxN'
      'XvKNuS33oRANyZk0YYCZgXsShgIUoVE6WMjlJEJ2iGI4yU\ntDJ'
      'OFY8B+iWkweWOUhGLAIIGzlTmLCl1FJs5M0MxNKAZyHSmEWCAK'
      'UCl6FLTE1aGsmEBDUDAwmfm\nrN0VrzIU64f1GOC2RZOBDQlmgu'
      'PU8eP0E4aqE2PVcf6dT6mjuMxZ8mNLXqmjpFlosvLNGGC/Fxlu'
      '\n5EpPWDk1ZHrXRhBdBsAqNP+lcHm1u8qPn4cw4rA7Whk7O+LeK'
      'SFTFZRCRam78HeKWHQhZ4tg+0dT\nzheWT8scJQqKhb7vg2GAY1'
      'VxLyVt1TFBgQXgs4asneWv+Nq4eMSpac0IXerooJsmGW4zKqN7'
      'Zo6t\ncVV9aTl9oeWHq/YCHnMMZH2dhx6PXfK78Du7ZFboLAABC'
      '88VLClzlvp6NjzmFw9OmxVxLw0p0BsB\nUtvmxEf1hw/XviNi0d'
      'ePD9MkbUzeykCmNwHUuKrXFq00uevlz3Iu5ErRpt4Zcc+UkGkB'
      'shxzI9fX\nTdknTB/nt/6oobUyW5KIhRhV7Mqhf41Tx/cOgPyWC'
      '88XLlVSKvkfCWYNzw99IVmbEpjhf4mjaHPJ\n+gbOJDPeBQBQkN'
      'qSnBmvGdrTAA7XHjxU938yPytgIUIZmRa7bMygcRQM6EtAGODz'
      '1twtpRtaxBZW\n3tyAAV4Q/egc44M9B+Bgzb5DtQfkDCAIIC2tu'
      'z1s5h9iFoM+pf3Vez9vOGkTrHJ+pkN0LIhZtCB6\nYU8A2Fa2Kb'
      'vxjJyGzCH3zcETn0lYqaN1oA/KLrZuK938vfUbOQwwwL83znvI'
      'dwa+AXi3Zv+h2gNe\n3RexqGOC5kctvCPiLtDHddx09J2at53IQ'
      'XlbNziR85GYx+ZFPdJdAF6v2HHC/LHX5oABHqFNXZe4\nSUEpQL'
      '+QQ7T/ufBP5c5SOf3+91EP+cRALoD3a995p2afnLY/1/jQ/JhH'
      'Qb/T29V73qvZr6G1XvvB\nwpjFD0Qt6EoA2ZYzm4rXqWm113cuj'
      'v3jzPDZoJ8q23Jme9nLXoNUCODaxI2jgm7qGgA17ur0S0/y\nmJ'
      'd+m5JSbUjaMlQzHPRrFTuurix8RsCC9HqNgtTLyTsSNMM6C8Ap'
      'OhZdnOdCLonjYYB1zKDtKbsN\nbCgYALIJ1vTLaRa+UZrBIEafe'
      'cObXrftpMZ0hNELV1dIu9/W9reN2DlA3G9z9rUb9rLeQgyr0Px'
      '8\n4TLva2mJ1/ZW7SpovSTtfpgi4vWR+8IU4WAgSUWrM2/Yo2OC'
      '2i8KdTgTVLoq9lbt8hPAjy15n5iO\nSHOmILU5+RU9EwwGniIUx'
      'jdHHtBIrjEZyGSZjpm5en8AvFGRKb3XSkP6lZTdBjYEDFQpKOW'
      '6xE1I\nMijCAK+6slwicOoYwL6qPRWucunDLx3y7GBVHBjYGq5J'
      'WpGwWiJEhAA2cOa/V+72AcCl1osf1R+W\n2AvkkHt+9MLJ3Xy/R'
      'l/RrYbJDxjnS08Gx81Hq1yVcgEcrNkvvd9wi2Gy37uv/VILYhY'
      'laVOkL6u9\ncHWFLABX7AU/2HIlvsiN3MviVxDTr9P6xJfDFGES'
      'naCJt3zdlO0FgICFF66uUFBKzysDcW3ixj66\nvdzNE7LiwahHB'
      'MnJ4Fj9B14AfGU5yyFO4jC/0o8fp59A7O5Q08NmpuhGIexxMrj'
      'UevG87Z9SWxFP\n5D9i5kyeo3767VHvdeEtMf1PTtGxOP9hh2iX'
      'WBnsG31Yfc2zCP/uAacaTtZzdSxkO/yjIJUWu5S4\nLy01rbktZ'
      'BoDGQkbf2jJ67gHNPINAhY8bzvACEUksdirRCw0cGYIPRqpotS'
      'DrnkMBJIn5XtX5Dlh\nAoAAICIACAAiAoAAICIACAAiAoAAICIA'
      'CAAiAoAAICIACAAiAoAAICIACAAiAoAAICIACAAiAoAA\nICIAC'
      'AAiAoAAICIACAAiAoAAICIACAAiAoAAIPJDP+fEOli7z1OSA4z'
      'xLcGThmuTiFny9a31/6+0\nFnh6XJuF7L2Rc9syCzPtLh+qPeAp'
      'P9+R+sMfjjkp8fQ30bVyIeeu8lctfGOHrwpYuD3sjva8zj8P\nQ'
      'ZMNv1FTagYyHf6JWPx79W7irEzlWM5Z+AZPZkIAFsc+df0cEKe'
      'OD2YNnnLL0ZD+ynJWIgkIUbsQ\nRpkVGRKFgW4OnqS9JuHSvyfh'
      'x2OXuJDL08csfOPnDZ8Sf71qR3mGdE2i34bO6DgKGqefkKob6X'
      'Gy\nhuybVTurPWSeI2qTQ2z9pjlHItUtSyluNkzyGIbOiZRKxcd'
      'Cdkd5BnFZQn8tWiUxUHPIvWbY+uvw\n/AeAWwyTpfPj/9RyIdty'
      'mhjdod6vO1hkL5RIODlWP2Fk0I1eFmKrh/1NYiZgKcW20s1kIP'
      'pvWfnm\nD+rekxh8EBbvirjP+0p4hC51kuE2qaUzpHaUZ0ikphu'
      'Yeq7waQ65JUKjGHXcWP14WVsRc4wPSpdr\nuNz605ayDcT0dr1W'
      'vs3MmSSav4JSbEza2nGD/u9/JWtT7jfOk0iBSUM6x3LuuOkosR'
      '4AcNx0NMt8\nTMJ9EYv3GOdemyfOCwAAwMPRi5IkCw7SkN5TtbP'
      'MUTLA3T9vy32r6nWV53qOGOAoZfRDnusqUZ4G\n+rS4ZTySGoho'
      'QK0oXFrpqhiw7hc5rmwqWSdd00dJKdcn/a/UnOrphWGaxCfjlg'
      'pYkPiwgIX0S082\nC00D0P0yZ8mqwj9Jt1GE0fTQmeGS6T6lrgf'
      'Mirh7dNAYacIiENPyHy1zlg4o90sdxasKl0u3ThGL\ntxgmPRab'
      'Jv1V3vOG/uHCXJtgla4kgzF6beRb0cqYgeB+pav82ctLpANFDL'
      'BRGf1Kym6l50zo3ntA\nm7aMyPRaPg5AmH4pLc/6fb93/5zlzHM'
      'FSznMSb8NYfRSUoZX92UBCFdELI1/Vro6AQSQx9yqK8s/\nMR3p'
      'x+5/YjqSUbqRQ26vVbc3J78qs7qO3NTFZy1fbC972euBMcC3Gi'
      'Y/l7C6/7n/YtGaf9q+8+qA\nU3QuGZI+K+IemV/rQ+7od2v2H6h'
      '5y2u3EjCfpE15Ku6ZflPWsMRRtL18S7Hjqtca2yIWF8f+8U7Z\n'
      '7gNfk3dnmY55rUzWfiqPDX5yduR9XptMgOtI/ftvVb0uXdGrTR'
      'zi0uKWzYq426fv9zl7epbp2GsV\nW1WU98qqPOLG6Mc9FZduVEb'
      '1RestfOOm4r9dtufLKS4vYOGxwWl3R87x9Sj+pK8/Yfr4zaqdM'
      't/s\nRu4FMYvmRM5VyAgJAkQu5PzMnLWncqfMmtQY4LlR832tpe'
      '0/AABArvW7DcVrZA4vCIt61jA74t77\njfMC3/2P6g5lmY+ZOZO'
      'cYQcA4MbutcM3/drf0jr+F3C4ai94qXithW+UU/MeAMBjPl499'
      'OGYRaN1\nN6lk1IbuYdlF++XW/O3lWyxco/yGr2eCNyRlxKgG+3'
      '3cTlXQcIqO1VdXlDqKfPqUklLOCJ+1MObx\nALEeA/x21RunG0/'
      '5dN8NwihCGZl5w16ZtLoFQJt2lGV83nhSZodt7w0sVMwKv/vXw'
      'RNGBY2BveR7\nfsuFnKbsUw0nBMwzMmbaawOeGeGznh6yvPOn0T'
      'U1ZPKs379YvMY/F2jI/E/o9LnGBSGK0J6JWc2c\n6d3a/WcaT0E'
      'A/ThiWxHVZMnrJT0NAABgE6x7q3Z9aj6u9b3OnogFDPAQdUK8e'
      'lhq0MhRujGdGVU7\nVIWz7GLrj1fsBYX2y5XOMgayMqeu6zru1J'
      'DpiwY/EcwauurEuriK0peW029UZjpEO+Xvje8iFgUs\n0JCaHDJ'
      'tgv7WJO0IFaViKQULGYZivX4twojHPI95EQstgq3QXpDTlJ1r/'
      'VbEIgMZP0xv76kKqHgi\n7ulpobd3bcvo+jJWFr7xw7r3jtZ/oO'
      'xc4I8wwgAhgFWUSkvr1JRaTWuUlAoArKRU8ZqE9jszMMCl\njuK'
      '27UI3ctvFVqfodCGXEzkoACGkqM49BuEUHfOjH70n8v7uqGPXX'
      'XXEKpxlmRVbr9gL/BtnvbbH\n6+6L8btpSx8FApikHZEe/3xkty'
      '3mu7GQGwa42lm5rvgvJndddxjUreIxH8qGrU3cOESd0K2hQU9U'
      '\n0vu66ctTDSfyrLk0pAOcRNs4NlY/fkbYHROCJ/bAEXuulKFDt'
      'G8uWX+h5Xwg74+O1Y9fnvBnOVuN\nfQ9Am0xc3TfNOecsZ39quc'
      'BSrE/Ln24aagQk3DhozJSQqeP0N/d8wdJeK+bpEO3v1717znKm'
      'VWjh\nsBt0w1wtMTlhgJWUSkNppobd/qBxQSe3E/okgHYv6t11h'
      'fZLOU1ffW/9h1N0shTLdk+34DEvIF5F\nqycaptwaPCVBMyxSYa'
      'RgLz+oG1jlbKtdVXm27/JsuWZ3fYvY4hSdTuRoC2QhgBBCORel'
      'f1lDYISR\nltFqaZ2a0oQoQscNmjBWP36wKjagZp0ArSfMY55Hf'
      'NsWRZ41t8RZVOkqswm2Insh13YzGgTtyysM\nMMYYA6xn9XGqeA'
      'TQjUG/StKMSNAO01BahmIYwLAUCwJSfbigczPfhAEAAMu8AYQA'
      'IOpAJFcEAUAA\nEPWi/gXINMF3jnwvqgAAAABJRU5ErkJggg=='
    ]

    meta =
      type: "image/png"
      length: 0
      sender:
        name: "Karl Rieb"
        email: "karl.rieb@gmail.com"
        
    @sendDataz meta, data
    
  emitEvent: (event, data) ->
    @socket.emit event, data