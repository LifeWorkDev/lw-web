# LifeWork Web App

* [About LifeWork](#about-lifework)
* [Developer setup](#developer-setup)
* [Workflow](#workflow)
* [Code standards](#code-standards)

## About LifeWork

Our app is designed to make it easy for independent freelancers who do not use a platform like UpWork to get paid reliably for their work. We are building a service that charges the client up-front and holds the money in escrow until work is completed, and then immediately pays the freelancer without the need for invoices, checks or transfer instructions. You can read more about us on [our website](https://www.lifeworkonline.com/).

Our app consists of the following models:

* User - a user can belong to an Organization (in which case they're considered a client), can be a freelancer, or both
* Org - an organization, also known as a client when associated with a project
* Project - something that a freelancer works on for a client. This is an [STI model](https://guides.rubyonrails.org/association_basics.html#single-table-inheritance)
* Milestone Project - a specific type of project that has Milestones, each with a date and payment amount

Here is the typical workflow:

1. Freelancer creates a new Client, and a Milestone Project for that Client
1. Freelancer chooses the Milestones for that project, entering a date and amount for each milestone
1. LifeWork sends an invitation email to the Client informing them that the Freelancer has created a project and invites them to create an account with LifeWork, enter payment details, and confirm the project & milestones

Note that the Freelancer does most of the interacting with LifeWork. We are trying to make it as low-effort as possible for Clients.

#### Namespaces

Controllers & views are namespaced under Client & Freelancer. The routes have shorthand namespaces, `/c/` for Client & `/f/` for Freelancer.

## Developer setup

1. `git clone git@github.com:swrobel/lw-web.git && cd lw-web`
1. Install dependencies using [Homebrew](https://brew.sh/): `brew bundle`
1. If on Linux:
    * `brew link --force nss`
    * `pg_ctl -D /home/linuxbrew/.linuxbrew/var/postgres start`
1. `mkcert -install`
1. `cd config/ssl && mkcert lifework.localhost lifework-packs.localhost mail.localhost localhost 127.0.0.1 ::1 && cd ../../`
1. `gem install bundler -v '>= 2.0.2'`
1. `bundle`
1. `yarn`
1. `cp config/database.yml.example config/database.yml`
1. `bin/rails db:setup`
1. `rvmsudo bin/invoker setup --tld localhost` (help available [here](http://invoker.codemancers.com/ruby_managers.html))
1. `bin/server`
1. Open https://lifework.localhost
1. To view outbound emails, open https://mail.localhost

There isn't currently any seed data. You will need to register as a new user and create a project. If you use the same email address you signed up with as the Client Email when creating a project, your same user account can be both Client & Freelancer. Access the client dashboard by going to https://lifework.localhost/c/projects

## Workflow

* We use Pivotal Tracker to specify "stories" that explain a particular bug, feature or chore that needs to be coded.
* Anything that is in the "Current Iteration/Backlog" in Pivotal is available to be worked on, as long as it isn't assigned to another developer.
* Each Pivotal story should be worked on in its own branch, and submitted as a Github Pull request when done.
* Branches should be prefixed with their pivotal story type, ex: `fea/` (feature), `bug/`, `chore/`
* Branches should contain the Pivotal story ID, which can easily be copied from the story by clicking the ID button as shown below.

  ![Copy Pivotal Story ID](https://www.pivotaltracker.com/help/kb_assets/working_with_stories_2@2x.png)
* Branches should be named short, but descriptively. For example, for a chore called "Convert milestones calendar to React Day Picker" with ID 168058495 a good branch name would be `chore/react-day-picker-milestones-#168058495`
* Do not push directly to `master`
* Commit early, commit often! Don't wait until the end of the day to commit your work.
* Commits should always be descriptively named so that it's easy to figure out what was done.
* Commits should always be atomic. This means that each commit should only reflect one unit of work. Work from different features should not be mixed together in a single commit. If you think that the git commit message will be really long to explain what you've done, you should probably break your work up into multiple commits. Make use of `git add` to only stage the files that are necessary for a particular commit. Get out of the habit of using `git add .`

## Code standards

We use the following linters/formatters:

* [rubocop](https://docs.rubocop.org/en/stable/) (Ruby/Rails format/lint)
* [prettier](https://prettier.io/) (JavaScript/JSX format)
* [eslint](https://eslint.org/) (JavaScript/JSX lint)
* [slim-lint](https://github.com/sds/slim-lint) (Rails view lint)
* [stylelint](https://stylelint.io/) (Stylesheet lint)

They should all run automatically when you've started the app with `bin/server` & you should receive notifications when something fails. All rules that can be auto-fixed are set up to do so.

#### Deviations from the defaults:

Ruby:

* Please always use keyword args when building methods that take more than one argument. ex:
  * Good: `def method(arg)`
  * Good: `def method(arg1:, arg2: nil)`
  * Bad: `def method(arg1, arg2 = nil)`
* Indent access modifiers (`protected`, `private`) the same as the class definition, ex:
  ```ruby
  class A
    def method
    end

  private

    def priv_method
    end
  end
  ```
* There is no limit on line-length enforced. It's assumed that your editor can wrap long lines.
* Trailing commas at the end of multi-line hashes/arrays:
  ```ruby
  {
    a: 1,
    b: 2, # <--
  }
  ```

JavaScript:

* No semicolons at ends of lines
* Single quotes `''` preferred
* Trailing commas at the end of multi-line objects/arrays:
  ```js
  {
    a: 1,
    b: 2, // <--
  }
  ```
