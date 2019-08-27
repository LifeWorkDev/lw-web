# LifeWork Web App

## Developer setup

1. `brew install postgresql`
1. `brew services start postgresql`
1. `brew install nss mkcert`
1. `mkcert -install`
1. `cd config/ssl && mkcert lifework.test lifework-packs.test localhost 127.0.0.1 ::1 && cd ../../`
1. `bin/rails db:setup`
1. `rvmsudo invoker setup` (help available [here](http://invoker.codemancers.com/ruby_managers.html))
1. `bin/server`
1. Open https://lifework.test

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
