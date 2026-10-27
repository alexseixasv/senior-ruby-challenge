module Api
  class BaseController < ApplicationController
    include AccountAuthentication
  end
end
