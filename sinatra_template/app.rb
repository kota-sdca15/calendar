require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require 'rubygems'
require 'date'
require './models'

enable :sessions

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
  Calendar.create(name: params[:name],password: params[:password],password_confirmation: params[:password_confirmation],lock: params[:private])
  d = Date.today
  @year = d.year
  @month = d.month
  erb :calendar
end

post '/tasks' do
  Task.create(title: params[:task],date: params[:date])
  session[:date] = params[:date]
  redirect '/calendar'
end

get '/calendar' do
  ＠task_date = Date.parse("#{session[:date]}.to_i")
  @year = ＠task_date.year
  @month = ＠task_date.month
  @date = ＠task_date.day
  erb :calendar
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
