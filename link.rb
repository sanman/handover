require 'main.rb'

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

#----------Links start here-------------------------
## list all links
get '/links' do
  @links = Link.all
  haml :index_link
end

# create new 
post '/link/create' do
   
  link  = Link.new(params[:title])
  link.name = params[:name]
  p link.inspect
  p link.class

  if link.save
    status 201
    redirect '/links'
  else
    status 412
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
  #task.name = (params[:name])
  if link.save
    status 201
    redirect '/links'
  else
    status 412
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
  redirect '/links'
end
DataMapper.auto_upgrade!
