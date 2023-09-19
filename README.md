# Collaborative RSA

This repository contains my project for my master thesis.
The software implements a collaborative learning approach to learn asymmetric encryption with the [RSA](<https://en.wikipedia.org/wiki/RSA_(cryptosystem)>) cryptosystem.
Therefore I used the [Elixir](https://elixir-lang.org/) based webframework [Phoenix](https://www.phoenixframework.org/).
Before I started this master thesis project I had no experience with big projects in Phoenix.
I just learned the programming language and the framework in the web applications course at my university HTW.
So this was my first big project in Elixir and Phoenix.

In the project I used Phoenix LiveView to create a real-time interaction between the users.
That worked pretty well and building something with Phoenix was easier that I first tought.

## Requirements

- mix
- npm
- postgreSQL Database

## Setup

To start the application run the following command:

- add the correct database config to `dev.exs`
- Run `mix setup` to install and setup dependencies
- Run `npm install` to install JavaScript dependencies
- Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
