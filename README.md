# redis-orm

Easy-to-use object relational mapping for Redis.

## Disclaimer

The gem is intended to be similar to ActiveRecord; however, it's not identical. Most notably, a lot of options that ActiveRecord gives you are currently missing from `redis-orm`. This is mostly because I'm just one guy, and I have other projects I'd like to make some headway on. As time goes on, expect `redis-orm` to become more and more ActiveRecord-like. The end goal is to produce a Redis library that is a drop-in replacement for ActiveRecord in a Rails 3 project (but that is also usable outside of Rails).

And by the way, I'm totally accepting pull requests. Hint, hint.

## Requiring

Add it to your Gemfile if you're using one. If necessary, require the redis-orm libraries like so:

    require 'redis-orm'
    
    # -or-
    
    require 'redis/orm'

...whichever one strikes your fancy.

## Usage

Inherit from `Redis::ORM` as if you were inheriting from `ActiveRecord::Base`:

    class User < Redis::ORM
      # more code here!
    end

At this point your Accounts can be created, saved, and so forth. It might be helpful to define attributes on the model, however, or else the model will be quite useless indeed!

### attributes

Instead of defining them in a schema file or set of migrations, `redis-orm` defines attributes directly within the model:

    class User < Redis::ORM
      attribute :login
      attribute :password
    end
    
Attributes can have any value that can be serialized. The default serializer is `Marshal`, but more on that later.

Optionally, you can give attributes a default value. If not specified, the default value is implicitly `nil`.

    class Post < Redis::ORM
      attribute :subject, "(No subject.)"
      attribute :body
    end
    
Like `ActiveRecord`, `redis-orm` defines `created_at` and `updated_at` attributes for you automatically, so you don't need to worry about these. Additionally, the `id` field is created and managed for you.

### relationships

There are 3 core relationships defined by `redis-orm`: `belongs_to`, `has_one` and `has_many`. They function essentially similar to relations of the same name in ActiveRecord, but it's important to keep in mind that they are specifically designed for Redis, and they have some minor differences.

    class User < Redis::ORM
      has_many :posts, :relation => :user
      has_one :profile, :relation => :user
    end
    
    class Post < Redis::ORM
      belongs_to :user
    end

    class Profile < Redis::ORM
      belongs_to :user
    end
    
As shwon above, you should usually follow your `has_one` and `has_many` directives with a `relation` option, which matches the corresponding `belongs_to` relation in the other models. Think of it as the `foreign_key` option in ActiveRecord. This option is not strictly required and `redis-orm` will work fine without it, but you may have problems looking up the reverse relations (e.g. the `belongs_to` part) without it.

Alternatively, you can specify a `relation` option for the `belongs_to` directive, instead:

    class User < Redis::ORM
      has_many :posts
      has_one :profile
    end

    class Post < Redis::ORM
      belongs_to :user, :relation => :posts
    end

    class Profile < Redis::ORM
      belongs_to :user, :relation => :profile
    end

TODO: A future version of this gem will infer the `relation` option from the class name if it omitted.


#### inference

Unlike `ActiveRecord`, `redis-orm` does _not_ infer class names from the relation name. You can give any value you like to the relations. During look-up, class names are retrieved from the object's ID, which (as mentioned) is already maintained for you. So in most cases, you should not have to care about the object's class at all. The only caveat is, all related objects _must_ inherit from `Redis::ORM` so that they can be looked up and deserialized properly.

### validations

The `Redis::ORM` base class automatically pulls in `ActiveModel::Validations`, so you should look at those. In addition, a Redis-specific `validates_uniqueness_of` validation has been added, and can be used thusly:

    class User < Redis::ORM
      attribute :login
      
      validates_uniqueness_of :login
    end

## Actions

Now we get to discuss things you can actually _do_ with your Redis-based models!

### creating and saving records

You can instantiate a new record by simply calling _new_, just like any Ruby object. Supply an optional hash of attributes:

    new_user = User.new()                        #=> a user with no attributes
    new_user = User.new(:login => "Colin")       #=> a user named Colin, but with no password
    new_user = User.new(:profile => Profile.new) #=> a user with a profile (it has_one, remember?)
    
So far, none of these records have been saved. Let's do that now:

    if new_user.save
      # save successful, do something
    else
      # save failed, let's get the error messages
      puts new_user.errors.full_messages
    end

The `save` method returns `true` if the save was successful, `false` otherwise. If the save failed, the model's `errors` object will have been populated.

The `errors` object comes straight from `ActiveModel`, so using it is identical to that of `ActiveRecord`.

You can call `save!` instead of `save` if you prefer an actual exception to be raised if the record couldn't be saved. The exception will include the full error messages, so you will know if the save failed due to validations.

You can also make use of the ActiveRecord-esque `create` method:

    new_user = User.create(:login => 'Colin')
    
The model instance will be returned whether the record was successfully saved or not. If you would prefer an error to be raised upon failing validations, you can call `create!` instead.

### finding records

Finding an existing record is done like so:

    user = User.find('id_of_user')
    
If the record could not be found, `nil` will be returned.

Dynamic `find_by_*` methods are not supported at this time.

### destroying records

Destroying records is easy:

    user = User.find('id_of_user')
    user.destroy
    
To destroy all records of a given type, call `destroy_all` on the model class:

    User.destroy_all

## Callbacks

The following callbacks are supported, and are used just like their `ActiveRecord` counterparts:

* before_initialize
* after_initialize
* around_initialize
* before_save
* after_save
* around_save
* before_create
* after_create
* around_create
* before_update
* after_update
* around_update
* before_destroy
* after_destroy
* around_destroy

In addition, you can register behavior to happen _during_ some actions, specifically saving and destroying:

    class User < Redis::ORM
      within_save_block :save_extra_stuff
      within_destroy_block :delete_extra_stuff
      
      def save_extra_stuff
        # hardcore low-level database action
      end
      
      def delete_extra_stuff
        # crazy low-level database madness
      end
    end

You can use these callbacks to perform commands directly upon the Redis database connection, and they will be rolled into the corresponding save and destroy transaction blocks. This way, if the saving or destroying of the model should fail at any point during the save or destroy process respectively, the entire transaction will be rolled back and you can rest assured that you haven't needlessly altered the database beyond recognition.

## Configuration


### connection

You can set the host and port for Redis:

    Redis.host = 'localhost'
    Redis.port = 3200
  
If you already have an active connection, however, these changes will not take effect. You'll need to replace the connection directly:

    Redis.connection = Redis.new(:host => 'localhost', :port => 3000)


### serializer

By default, Redis serializes the attributes using Marshal. If you would prefer to store data in some other format, simply replace Redis::ORM.serializer with your choice. Anything that responds to #dump and #load will work (JSON, YAML, etc):

    Redis::ORM.serializer = YAML

Obviously, you can use your own custom serializer just as easily. Just pass in an object that returns a string for `#dump(object)` and an object for `#load(string)` and you're good to go.

It's worth noting that there can only be one serializer for all models. It's also worth noting that it's a Bad Idea to switch serializers once you've got a database full of data. If you need to switch, for instance, from JSON to YAML serialization, you'll need to come up with a migration scheme yourself.
