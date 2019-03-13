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
        calendar << '<a href="/' + _year.to_s + '/' + _month.to_s + '/' + ((cal_count - first_date.wday + 1).to_s if first_date.wday <= cal_count && last_date.day > cal_count - first_date.wday).to_s + '/">'
        calendar << (cal_count - first_date.wday + 1).to_s if first_date.wday <= cal_count && last_date.day > cal_count - first_date.wday
        calendar << '<br>'

        # date = ((cal_count - first_date.wday + 1).to_s
        # if first_date.wday <= cal_count && last_date.day > cal_count - first_date.wday).to_s
       '@year' << "." << '@month' << "." << '@date' == @task_date
          todo = Task.where("'@year' << "," << '@month' << "," << '@date'" == '@task_date')



        calendar << '</a>'

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

post '/calendar' do
  @year = params[:year].to_i
  @month = params[:month].to_i
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