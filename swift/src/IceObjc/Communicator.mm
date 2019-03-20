// **********************************************************************
//
// Copyright (c) 2003-2018 ZeroC, Inc. All rights reserved.
//
// This copy of Ice is licensed to you under the terms described in the
// ICE_LICENSE file included in this distribution.
//
// **********************************************************************

#import "IceObjcCommunicator.h"
#import "IceObjcObjectPrx.h"
#import "IceObjcLogger.h"
#import "IceObjcImplicitContext.h"
#import "IceObjcProperties.h"

#import "LoggerWrapperI.h"
#import "IceObjcUtil.h"

#include <Ice/Instance.h>
#include <Ice/DefaultsAndOverrides.h>

@implementation ICECommunicator

-(instancetype) initWithCppCommunicator:(std::shared_ptr<Ice::Communicator>)communicator
{
    self = [super initWithLocalObject:communicator.get()];
    if(self)
    {
        self->_communicator = communicator;
    }
    return self;
}

-(void) destroy
{
    _communicator->destroy();
}

-(void) shutdown
{
    _communicator->destroy();
}

-(void) waitForShutdown
{
    _communicator->waitForShutdown();
}

-(bool) isShutdown
{
    return _communicator->isShutdown();
}

-(id) stringToProxy:(NSString*)str error:(NSError**)error
{
    try
    {
        ICEObjectPrx* prx = [[ICEObjectPrx alloc] initWithCppObjectPrx:_communicator->stringToProxy(fromNSString(str))];
        if(prx)
        {
            return prx;
        }
        else
        {
            return [NSNull null];
        }
    }
    catch(const std::exception& e)
    {
        *error = convertException(e);
    }

    return nil;
}

-(NSString*) proxyToString:(ICEObjectPrx*)prx error:(NSError* _Nullable * _Nullable)error
{
    try
    {
        return toNSString(_communicator->proxyToString([prx prx]));
    }
    catch(const std::exception& ex)
    {
        *error = convertException(ex);
        return nil;
    }
}

-(nullable id) propertyToProxy:(NSString*)property error:(NSError* _Nullable * _Nullable)error
{
    try
    {
        auto prx = _communicator->propertyToProxy(fromNSString(property));
        if(prx)
        {
            return [[ICEObjectPrx alloc] initWithCppObjectPrx:prx];
        }
        return [NSNull null];
    }
    catch(const std::exception& ex)
    {
        *error = convertException(ex);
        return nil;
    }
}

-(NSDictionary<NSString*, NSString*>*) proxyToProperty:(ICEObjectPrx*)prx property:(NSString*)property error:(NSError* _Nullable * _Nullable)error
{
    return toNSDictionary(_communicator->proxyToProperty([prx prx], fromNSString(property)));
}

//-(ObjectAdapterI*) createObjectAdapter:(NSString*)name error:(NSError* _Nullable * _Nullable)error
//{
////    try
////    {
//////        communicator->createObjectAdapter(fromNSString(name));
////    }
////    catch(const std::exception& ex)
////    {
////        *error = convertException(ex);
////        return nil;
////    }
//    assert(false);
//}
//
//-(ObjectAdapterI*) createObjectAdapterWithEndpoints:(NSString*)name endpoints:(NSString*)endpoints error:(NSError* _Nullable * _Nullable)error
//{
//    assert(false);
//}
//
//-(ObjectAdapterI*) createObjectAdapterWithRouter:(NSString*)name router:(_RouterPrxI*)router error:(NSError* _Nullable * _Nullable)error
//{
//    assert(false);
//}

-(ICEImplicitContext*) getImplicitContext
{
    auto implicitContext = _communicator->getImplicitContext();
    return createLocalObject<Ice::ImplicitContext>(implicitContext, [&implicitContext] () -> id
    {
        return [[ICEImplicitContext alloc] initWithCppImplicitContext:implicitContext];
    });
}

// id<ICELoggerProtocol> may be either a Swift logger or a wrapper around a C++ logger
-(id<ICELoggerProtocol>) getLogger
{
    auto logger = _communicator->getLogger();

    auto swiftLogger = std::dynamic_pointer_cast<LoggerWrapperI>(logger);
    if(swiftLogger)
    {
        return swiftLogger->getLogger();
    }

    return createLocalObject<Ice::Logger>(logger, [&logger] () -> id
    {
        return [[ICELogger alloc] initWithCppLogger:logger];
    });
}

-(nullable ICEObjectPrx*) getDefaultRouter
{
    return [[ICEObjectPrx alloc] initWithCppObjectPrx:_communicator->getDefaultRouter()];
}

-(BOOL) setDefaultRouter:(ICEObjectPrx*)router error:(NSError**)error
{
    try
    {
        auto r = router ? [router prx] : nullptr;
        _communicator->setDefaultRouter(Ice::uncheckedCast<Ice::RouterPrx>(r));
        return YES;
    }
    catch(const std::exception& ex)
    {
        *error = convertException(ex);
        return NO;
    }
}

-(nullable ICEObjectPrx*) getDefaultLocator
{
    return [[ICEObjectPrx alloc] initWithCppObjectPrx:_communicator->getDefaultLocator()];
}

-(BOOL) setDefaultLocator:(ICEObjectPrx*)locator error:(NSError**)error
{
    try
    {
        auto l = locator ? [locator prx] : nullptr;
        _communicator->setDefaultLocator((Ice::uncheckedCast<Ice::LocatorPrx>(l)));
        return YES;
    }
    catch(const std::exception& ex)
    {
        *error = convertException(ex);
        return NO;
    }
}

-(BOOL) flushBatchRequests:(uint8_t)compress error:(NSError**)error
{
    try
    {
        _communicator->flushBatchRequests(Ice::CompressBatch(compress));
        return YES;
    }
    catch(const std::exception& ex)
    {
        *error = convertException(ex);
        return NO;
    }
}

-(BOOL) flushBatchRequestsAsync:(uint8_t)compress
                      exception:(void (^)(NSError*))exception
                           sent:(void (^_Nullable)(bool))sent
                          error:(NSError**)error
{
    try
    {
        _communicator->flushBatchRequestsAsync(Ice::CompressBatch(compress),
                                               [exception](std::exception_ptr e)
                                               {
                                                   exception(convertException(e));
                                               },
                                               [sent](bool sentSynchronously)
                                               {
                                                   if(sent)
                                                   {
                                                       sent(sentSynchronously);
                                                   }
                                               });
        return YES;
    }
    catch(const std::exception& ex)
    {
        *error = convertException(ex);
        return NO;
    }
}

-(ICEProperties*) getProperties
{
    auto props = _communicator->getProperties();
    return [[ICEProperties alloc] initWithCppProperties:props];
}

-(void) getDefaultEncoding:(nonnull uint8_t*)major minor:(nonnull uint8_t*)minor
{
    auto defaultEncoding = IceInternal::getInstance(_communicator)->defaultsAndOverrides()->defaultEncoding;
    *major = defaultEncoding.major;
    *minor = defaultEncoding.minor;
}

-(uint8_t) getDefaultFormat
{
    return static_cast<uint8_t>(IceInternal::getInstance(_communicator)->defaultsAndOverrides()->defaultFormat);
}
@end