# frozen_string_literal: true

ServiceGraphDev::Engine.routes.draw do
  root  to: "graphs#show"
  get   "data",    to: "graphs#data",    as: :data
  post  "refresh", to: "graphs#refresh", as: :refresh
  get   "mermaid", to: "graphs#mermaid", as: :mermaid
  get   "vis-network.js", to: "graphs#vis_network_js", as: :vis_network_js
end
