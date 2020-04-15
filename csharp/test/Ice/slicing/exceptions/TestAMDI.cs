//
// Copyright (c) ZeroC, Inc. All rights reserved.
//

using Ice;
using System.Threading.Tasks;
using Test;

public sealed class TestIntf : ITestIntf
{
    public ValueTask shutdownAsync(Current current)
    {
        current.Adapter.Communicator.Shutdown();
        return new ValueTask(Task.CompletedTask);
    }

    public ValueTask baseAsBaseAsync(Current current) => throw new Base("Base.b");

    public ValueTask unknownDerivedAsBaseAsync(Current current) =>
        throw new UnknownDerived("UnknownDerived.b", "UnknownDerived.ud");

    public ValueTask knownDerivedAsBaseAsync(Current current) =>
        throw new KnownDerived("KnownDerived.b", "KnownDerived.kd");

    public ValueTask
    knownDerivedAsKnownDerivedAsync(Current current) =>
        throw new KnownDerived("KnownDerived.b", "KnownDerived.kd");

    public ValueTask
    unknownIntermediateAsBaseAsync(Current current) =>
        throw new UnknownIntermediate("UnknownIntermediate.b", "UnknownIntermediate.ui");

    public ValueTask
    knownIntermediateAsBaseAsync(Current current) =>
        throw new KnownIntermediate("KnownIntermediate.b", "KnownIntermediate.ki");

    public ValueTask
    knownMostDerivedAsBaseAsync(Current current) =>
        throw new KnownMostDerived("KnownMostDerived.b", "KnownMostDerived.ki", "KnownMostDerived.kmd");

    public ValueTask
    knownIntermediateAsKnownIntermediateAsync(Current current) =>
        throw new KnownIntermediate("KnownIntermediate.b", "KnownIntermediate.ki");

    public ValueTask
    knownMostDerivedAsKnownIntermediateAsync(Current current) =>
        throw new KnownMostDerived("KnownMostDerived.b", "KnownMostDerived.ki", "KnownMostDerived.kmd");

    public ValueTask
    knownMostDerivedAsKnownMostDerivedAsync(Current current) =>
        throw new KnownMostDerived("KnownMostDerived.b", "KnownMostDerived.ki", "KnownMostDerived.kmd");

    public ValueTask
    unknownMostDerived1AsBaseAsync(Current current) =>
        throw new UnknownMostDerived1("UnknownMostDerived1.b", "UnknownMostDerived1.ki", "UnknownMostDerived1.umd1");

    public ValueTask
    unknownMostDerived1AsKnownIntermediateAsync(Current current) =>
        throw new UnknownMostDerived1("UnknownMostDerived1.b", "UnknownMostDerived1.ki", "UnknownMostDerived1.umd1");

    public ValueTask
    unknownMostDerived2AsBaseAsync(Ice.Current current) =>
        throw new UnknownMostDerived2("UnknownMostDerived2.b", "UnknownMostDerived2.ui", "UnknownMostDerived2.umd2");

    public ValueTask
    unknownMostDerived2AsBaseCompactAsync(Current current) =>
        throw new UnknownMostDerived2("UnknownMostDerived2.b", "UnknownMostDerived2.ui", "UnknownMostDerived2.umd2");

    public ValueTask knownPreservedAsBaseAsync(Current current) =>
        throw new KnownPreservedDerived("base", "preserved", "derived");

    public ValueTask
    knownPreservedAsKnownPreservedAsync(Current current) =>
        throw new KnownPreservedDerived("base", "preserved", "derived");

    public ValueTask serverPrivateExceptionAsync(Current current) => throw new ServerPrivateException("ServerPrivate");

    public ValueTask
    relayKnownPreservedAsBaseAsync(IRelayPrx? r, Current current)
    {
        TestHelper.Assert(r != null);
        IRelayPrx p = current.Connection!.CreateProxy(r.Identity, IRelayPrx.Factory);
        try
        {
            p.knownPreservedAsBase();
        }
        catch (RemoteException ex)
        {
            TestHelper.Assert(ex.ConvertToUnhandled);
            ex.ConvertToUnhandled = false;
            throw;
        }
        TestHelper.Assert(false);
        return new ValueTask(Task.CompletedTask);
    }

    public ValueTask
    relayKnownPreservedAsKnownPreservedAsync(IRelayPrx? r, Current current)
    {
        TestHelper.Assert(r != null);
        IRelayPrx p = current.Connection!.CreateProxy(r.Identity, IRelayPrx.Factory);
        try
        {
            p.knownPreservedAsKnownPreserved();
        }
        catch (RemoteException ex)
        {
            TestHelper.Assert(ex.ConvertToUnhandled);
            ex.ConvertToUnhandled = false;
            throw;
        }
        TestHelper.Assert(false);
        return new ValueTask(Task.CompletedTask);
    }

    public ValueTask unknownPreservedAsBaseAsync(Current current)
    {
        var ex = new SPreserved2();
        ex.b = "base";
        ex.kp = "preserved";
        ex.kpd = "derived";
        ex.p1 = new SPreservedClass("bc", "spc");
        ex.p2 = ex.p1;
        throw ex;
    }

    public ValueTask
    unknownPreservedAsKnownPreservedAsync(Current current)
    {
        var ex = new SPreserved2();
        ex.b = "base";
        ex.kp = "preserved";
        ex.kpd = "derived";
        ex.p1 = new SPreservedClass("bc", "spc");
        ex.p2 = ex.p1;
        throw ex;
    }

    public ValueTask
    relayUnknownPreservedAsBaseAsync(IRelayPrx? r, Current current)
    {
        TestHelper.Assert(r != null);
        IRelayPrx p = current.Connection!.CreateProxy(r.Identity, IRelayPrx.Factory);
        try
        {
            p.unknownPreservedAsBase();
        }
        catch (RemoteException ex)
        {
            TestHelper.Assert(ex.ConvertToUnhandled);
            ex.ConvertToUnhandled = false;
            throw;
        }
        TestHelper.Assert(false);
        return new ValueTask(Task.CompletedTask);
    }

    public ValueTask
    relayUnknownPreservedAsKnownPreservedAsync(IRelayPrx? r, Ice.Current current)
    {
        TestHelper.Assert(r != null);
        IRelayPrx p = current.Connection!.CreateProxy(r.Identity, IRelayPrx.Factory);
        try
        {
            p.unknownPreservedAsKnownPreserved();
        }
        catch (RemoteException ex)
        {
            TestHelper.Assert(ex.ConvertToUnhandled);
            ex.ConvertToUnhandled = false;
            throw;
        }
        TestHelper.Assert(false);
        return new ValueTask(Task.CompletedTask);
    }

    public ValueTask relayClientPrivateExceptionAsync(IRelayPrx? r, Current current)
    {
        TestHelper.Assert(r != null);
        IRelayPrx p = current.Connection!.CreateProxy(r.Identity, IRelayPrx.Factory);
        try
        {
            p.clientPrivateException();
        }
        catch (RemoteException ex)
        {
            TestHelper.Assert(ex.ConvertToUnhandled);
            ex.ConvertToUnhandled = false;
            throw;
        }
        TestHelper.Assert(false);
        return new ValueTask(Task.CompletedTask);
    }
}
