//
//  APIConstants.h
//  Fanmento
//
//  Created by teejay on 10/19/12.
//  Copyright (c) 2012 VOKAL. All rights reserved.
//

#ifndef Fanmento_APIConstants_h
#define Fanmento_APIConstants_h

#pragma mark API

#define  API_ERROR              @"error"
#define  API_VERSION            @"v1/"
#define  API_USERS              @"user/"
#define  API_COLLECTION         @"image/"

#define  BASE_URL               @"http://fanmento-staging.appspot.com/api/"
//#define  API_IMAGE_FORMAT       @"http://fanmento-staging.appspot.com/api/v1/templates/template/%@/image"
//#define  API_AD_FORMAT          @"http://fanmento-staging.appspot.com/api/v1/templates/ad/%@/image"

// THESE LINES SHOULD NOT BE COMMITTED IF CHANGED
//#define  BASE_URL               @"http://mobile.fanmento.com/api/"

#define  API_TEMPLATES          @"templates/"
#define  API_CATEGORY           @"category/"
#define  API_VENUE              @"venue"
#define  API_GET_TEMPLATE       @"template/"
#define  API_CODE               @"template/%@"

#define  USER_PASSWORD          @"password"
#define  USER_EMAIL             @"email"
#define  USER_ID                @"id"
#define  USER_FB_TOKEN          @"facebook_token"
#define  USER_NAME              @"name"
#define  USER_PHONE             @"phone"

#define  USER_FQL               @"uid, email, name"

#define  TEMPLATE_CATEGORY      @"category"
#define  TEMPLATE_CODE          @"code"
#define  TEMPLATE_NAME          @"name"
#define  TEMPLATE_AD            @"ad"
#define  TEMPLATE_ADVERTISEMENT @"advertisement"
#define  TEMPLATE_BACKGROUND    @"background"
#define  TEMPLATE_AD_TARGET     @"link"
#define  TEMPLATE_REMOTE_IMAGE  @"url"
#define  TEMPLATE_PRODUCT_ID    @"product_id"
#define  TEMPLATE_DESCRIPTION   @"description"
#define  TEMPLATE_EFFECT        @"effect"
#define  TEMPLATE_VENUE         @"venue"
#define  TEMPLATE_PRICE         @"price"
#define  TEMPLATE_EXPIRES       @"expires"
#define  TEMPLATE_RELEASE       @"releases"
#define  TEMPLATE_NEARBY        @"isNearby"
#define  TEMPLATE_ID            @"id"
#define  TEMPLATE_PURCHASED     @"templatePurchased"
#define  TEMPLATE_FACEBOOK      @"facebook_message"
#define  TEMPLATE_TWITTER       @"twitter_message"
#define  TEMPLATE_EMAIL         @"email_message"
#define  TEMPLATE_CLIENT_NAME   @"client_name"
#define  TEMPLATE_TIMESTAMP     @"timestamp"

#define  VENUE_ADDRESS          @"address"
#define  VENUE_START            @"start_date"
#define  VENUE_END              @"end_date"
#define  VENUE_LOCATION         @"location"
#define  VENUE_ID               @"id"
#define  VENUE_NAME             @"name"

#define getUserToken()          [[NSUserDefaults standardUserDefaults] objectForKey:@"FBAccessTokenKey"]

#endif
