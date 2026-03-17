# frozen_string_literal: true

ServiceGraphDev::Engine.routes.draw do
  root  to: "graphs#show"
  get   "data",    to: "graphs#data",    as: :data
  post  "refresh", to: "graphs#refresh", as: :refresh
end
