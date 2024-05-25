u = User.new(username: 'guribeir', email: 'guribeir@student.42rj.org.br', name: 'gui', password: 'password', password_confirmation: 'password', admin: true)                                          
u.skip_confirmation!
u.save!
token = u.personal_access_tokens.create(scopes: ['api','write_repository'], name: 'install_token', expires_at: 365.days.from_now)
token.set_token('tokenwith20charactersistoolong')
token.save!
