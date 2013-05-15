require 'rubygems'
require 'sinatra'
require 'haml'
require 'data_mapper'
require 'sinatra/reloader'
require 'dm-core'
require 'dm-validations'
require 'dm-timestamps'
require 'sinatra/flash'
enable :sessions

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/development.db")

register Sinatra::Reloader
#set :environment, :production

class Task

  include DataMapper::Resource
  property :id,      Serial
  property :name,    String, :required => true, :unique => true,
      :messages => {
      :presence  => "Need to be a valid task.",
      :is_unique => "This task already exists.",
    }
  property :completed_at,  DateTime

  def completed?
    true if completed_at
  end

  def self.completed
    all(:completed_at.not => nil)
  end

  def link
    "<a href=\"task/#{self.id}\">#{self.name}</a>"
  end

end

class Link

  include DataMapper::Resource
  property :id,     Serial
  property :title,  String, :required => true, :unique => true,
      :messages => {
      :presence  => "Need to be a valid task.",
      :is_unique => "This title already exists.",
    }
  property :name,   String, :required => true, :unique => true,
      :messages => {
      :presence  => "Need to be a valid task.",
      :is_unique => "This url already exists.",
  }
    def linker
    "<a href=\"link/#{self.id}\">#{self.title}</a>"
    end

end

# list all tasks
get '/' do
  @tasks = Task.all
  haml :index
end

# create new task
post '/task/create' do
  task = Task.new(:name => params[:name])
  if task.save
    status 201
    flash[:success] = "New task created successfully."
    redirect '/'
  else
    status 412
    flash[:error] = "Task failed."
    redirect '/'
  end
end

 # edit task
get '/task/:id' do
  @task = Task.get(params[:id])
  haml :edit
end

# update task
put '/task/:id' do
  task = Task.get(params[:id])
  task.completed_at = params[:completed] ?  Time.now : nil
  task.name = (params[:name])
  if task.save
    status 201
    flash[:success] = "Task updated successfully."
    redirect '/'
  else
    status 412
    flash[:error] = "Failed to update the task."
    redirect '/'
  end
end

# delete confirmation
get '/task/:id/delete' do
  @task = Task.get(params[:id])
  haml :delete
end

# delete task
delete '/task/:id' do
  Task.get(params[:id]).destroy
  flash[:error] = "Task deleted successfully."
  redirect '/'
end


#----------Links start here-------------------------
## list all links
get '/links' do
  @links = Link.all
  haml :index_link
end

# create new
post '/link/create' do
  link  = Link.new(:title => params[:title], :name => params[:name])
  if link.save
    status 201
    flash[:success] = "New link for #{link.title} created successfully."
    redirect '/links'
  else
    status 412
    flash[:error] = "Failed to create new link."
    redirect    end
end

 # edit task
get '/link/:id' do
  @link = Link.get(params[:id])
  haml :edit_link
end

# update task
put '/link/:id' do
  link = Link.get(params[:id])
  #task.completed_at = params[:completed] ?  Time.now : nil
  link.title = (params[:title])
  link.name = (params[:name])
  if link.save
    status 201
    flash[:success] = "Link for #{link.title} updated successfully."
    redirect '/links'
  else
    status 412
    flash[:error] = "Failed to update link."
    redirect '/'
  end
end

# delete confirmation
get '/link/:id/delete' do
  @link = Link.get(params[:id])
  haml :delete_link
end

# delete task
delete '/link/:id' do
  Link.get(params[:id]).destroy
  flash[:error] = "Link deleted successfully."
  redirect '/links'
end

DataMapper.auto_upgrade!
