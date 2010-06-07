# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_room_session',
  :secret      => 'e7ccdc0841221b44c5895e185761277986079deaab6febc760c3e83c17c79c0e02cce761b50ef9d3a06f099b571fd36d54dc887fae5991ce7047175b0606eb6f'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
