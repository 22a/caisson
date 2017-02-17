# Caisson

Caisson is an Elixir Plug api that executes arbitrary untrusted code in hardened docker containers.

## Disclaimer
This is firmly a work in progress, don't use this for anything real. Don't blame me when your company goes on fire.

## Architecture
The system is composed of two main parts: a plug api which interacts with the docker daemon and a pre-hardened docker execution environment. The idea is that the docker execution environment is spun up on demand and killed when it's done its job.

## Assumptions
This api is built with the intention that, at some point in the future, a web app will be posting code to it and expecting the output. The idea is that the code will be accompanied by some metadata like the language it's written in as well as any runtime constraints that should be imposed on the execution. The assumption is that sumbitted code will try and destroy the machine, hog resources, and generally just do bad things whether intentional or by accident.

## Security
This system runs code in docker. Containers do not contain. This much is known.

A lot of the security concerns with docker is that root inside the container is root on the host system, so running things with even a whiff of privilege is asking for trouble so I've built the system around not doing that as well as some other security things. These things are:

* No network
* No capabilities
* nobody user

The idea is to compile/execute the untrusted code with the lowest privilege possible and to restrict access to the juicy kernel and system devices as much as possible. This completely crippled execution wouldn't work is we were trying to do anything complex but we're not, we're just running some code that doesn't need internet or device access.

## Setup
This'll be packaged up in it's own docker image at some point.
For now run it the brittle way:

### Prerequisites
* Elixir
* Docker
Have the docker daemon running.

Install the dependencies:
```bash
mix deps.get
```

Run the app:
```bash
mix run --no-halt
```
