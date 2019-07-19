require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require 'rubygems'
require 'date'
require './models'

enable :sessions

helpers do
  def current_user
    User.find_by(id: session[:user])
  end
end

def make_calendar(_year,_month)
  first_date = Date.new(_year,_month,1)
  last_date = Date.new(_year,_month,-1)

  calendar_size = last_date.day + first_date.wday - last_date.wday + 6

   calendar = ""
    calendar << '<table>' + "\n"
    calendar << "\t" + '<tr><td>日</td><td>月</td><td>火</td><td>水</td><td>木</td><td>金</td><td>土</td></tr>' + "\n"

    (calendar_size / 7).times do |n|
      calendar << "\t" + '<tr>'
      7.times do |i|
        cal_count = n*7 + i
        calendar << '<td>'
        @cal_date = _year.to_s + '/' + _month.to_s + '/' + ((cal_count - first_date.wday + 1).to_s if first_date.wday <= cal_count && last_date.day > cal_count - first_date.wday).to_s
        calendar << '<a href="/' + "#{@cal_date}" + '/">'
        calendar << (cal_count - first_date.wday + 1).to_s if first_date.wday <= cal_count && last_date.day > cal_count - first_date.wday
        calendar << '<br>'
        calendar << '</a>'
        calendar << '<p>'
        @date_plans = Array.new(0,nil)
        Task.all.each do |task|
          @date = task.date.strftime("%Y/%-m/%-d")
          if @cal_date == @date
            @date_plans.push(task.title)
          end
        end

        calendar << "#{@date_plans.join(", ")}"


        calendar << '</p>'

        calendar << '</td>'
      end
      calendar << '</tr>' + "\n"
    end
    calendar << '</table>'

    return calendar
end

get '/' do
   erb :index
end

get '/new' do
  erb :new
end

post '/calendar' do
  if Calendar.find_by(name: params[:name])
    @message = "この名前は既に使用されています"
    erb :new
  else
    make = Calendar.create(name: params[:name],password: params[:password],password_confirmation: params[:password_confirmation],lock: params[:private])
    session[:calendar] = make.id
    session[:name] = params[:name]
    d = Date.today
    @year = d.year
    @month = d.month
    @subscribe = Users_Calendar.find_by(user_id: session[:user], calendar_id: session[:calendar])
    redirect "/calendar/#{session[:name]}"
  end
end

post '/tasks' do
  Task.create(title: params[:title],date: params[:date])
  session[:date] = params[:date]
  redirect '/calendar/:name'
end

get '/:year/:month/:date/' do
  @year = params[:year].to_i
  @month = params[:month].to_i
  @date = params[:date].to_i
  search = "#{@month}/#{@date}/#{@year}"
  @date_plans = Array.new(0,nil)
  Task.all.each do |task|
    date = task.date.strftime("%-m/%-d/%Y")
    if search == date
      @date_plans.push(task.id)
    end
  end
  @tasks = Task.where(id: @date_plans)
  erb :date_plan
end

post '/login' do
  if Calendar.find_by(name: params[:name])
    session[:name] = params[:name]
    redirect "/calendar/#{session[:name]}"
  end
end

get "/calendar/:name" do
  Calendar.find_by(name: params[:name])
  d = Date.today
    @year = d.year
    @month = d.month
  @subscribe = Users_Calendar.find_by(user_id: session[:user], calendar_id: session[:calendar])
  erb :calendar
end

get '/sign_up' do
  erb :sign_up
end

post '/sign_up' do
  user = User.create(
    name: params[:username],
    email: params[:email],
    password: params[:password],
    password_confirmation: params[:password_confirmation]
  )
  if user.persisted?
    session[:user] = user.id
  end
  redirect '/signed'
end

get '/sign_in' do
  erb :sign_in
end

post '/sign_in' do
  user = User.find_by(email: params[:email])
  if user && user.authenticate(params[:password])
    session[:user] = user.id
    redirect '/signed'
  else
    redirect '/sign_in'
  end
end

get '/sign_out' do
  session[:user] = nil
  redirect '/'
end

get '/signed' do
  subscribed = Users_Calendar.where(user_id: session[:user])
  @calid = subscribed.pluck(:calendar_id)
  erb :signed
end

 post '/subscribe' do
   Users_Calendar.create(user_id: session[:user], calendar_id: session[:calendar])
   redirect "/calendar/#{session[:name]}"
 end
