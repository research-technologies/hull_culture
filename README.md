# Hull City of Culture Asset Manager Application

A gem for building the Hull City of Culture Asset Manager

## Deployment

1. Clone `hyrax_leaf` - a ready-made Hyrax instance (recommended)

```
git clone https://github.com/research-technologies/hyrax_leaf.git
```

Alternatively, deploy your own Hyrax instance using the [instructions](https://github.com/samvera/hyrax) provided by the Hyrax gem.

2. Clone the gem into vendor/hull_culture

```
cd PATH_TO_HYRAX/vendor
git clone https://github.com/research-technologies/hull_culture.git
```

If using the github url, skip this step

3. Add the gem to the Gemfile, install
```
# add to Gemfile
gem 'hull_culture', path: 'vendor/hull_culture'

# run:
bundle install
```

Alternatively use the github url with `gem 'hull_culture', git: 'https://github.com/research-technologies/hull_culture'`

4. Run the install generator (add  --initial on the first build)

```
rails g hull_culture:install --initial
```

5. Setup the ENV variables for production

With .rbenv-vars, copy this [production example file](https://github.com/research-technologies/hyrax_leaf/blob/master/.rbenv-vars-production-example) to the application root, rename to `.rbenv-vars` and set the values

By another mechanism, set the vars listed in this [production example file](https://github.com/research-technologies/hyrax_leaf/blob/master/.rbenv-vars-production-example) 
