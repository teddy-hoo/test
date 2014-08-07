# Simple Role Syntax
# ==================
# Supports bulk-adding hosts to roles, the primary server in each group
# is considered to be the first unless any hosts have the primary
# property set.  Don't declare `role :all`, it's a meta role.
set :stage, :staging
set :branch, "master"

role :app, %w{teddy@10.110.126.29}
role :web, %w{teddy@10.110.126.29}
role :db, %w{teddy@10.110.126.29}
