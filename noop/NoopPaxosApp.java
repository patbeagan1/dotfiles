package edu.umass.cs.gigapaxos.examples.noop;

import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

import edu.umass.cs.gigapaxos.examples.PaxosAppRequest;
import edu.umass.cs.gigapaxos.interfaces.Replicable;
import edu.umass.cs.gigapaxos.interfaces.Request;
import edu.umass.cs.gigapaxos.paxospackets.RequestPacket;
import edu.umass.cs.gigapaxos.paxospackets.PaxosPacket.PaxosPacketType;
import edu.umass.cs.nio.interfaces.IntegerPacketType;
import edu.umass.cs.reconfiguration.examples.noop.NoopApp;
import edu.umass.cs.reconfiguration.reconfigurationutils.RequestParseException;

/**
 * @author arun
 *
 */
public class NoopPaxosApp implements Replicable {

	@Override
	public boolean execute(Request request) {
		// execute request here

		String cache="HELLOWORLD";

		// set response if request instanceof InterfaceClientRequest
		if (request instanceof RequestPacket) {
			RequestPacket req = ((RequestPacket) request);
			if(req.requestValue.matches("write"+1)){
					cache=this.toString();
					req.setResponse("wrote "+this.toString()+" to cache.");				
			}
			else if(req.requestValue.matches("read"+1)){
					req.setResponse(cache);				
			}
			else{
				req.setResponse("appropriate_response_value");
			}
		}
		if (request instanceof PaxosAppRequest)
			((PaxosAppRequest) request)
					.setResponse(cache);
		return true;
	}

	@Override
	public boolean execute(Request request,
			boolean doNotReplyToClient) {
		// execute request without replying back to client

		// identical to above unless app manages its own messaging
		return this.execute(request);
	}

	@Override
	public String checkpoint(String name) {
		// should return checkpoint state here
		return null;
	}

	@Override
	public boolean restore(String name, String state) {
		// should update checkpoint state here for name
		return true;
	}

	/**
	 * Needed only if app uses request types other than RequestPacket. Refer
	 * {@link NoopApp} for a more detailed example.
	 */
	@Override
	public Request getRequest(String stringified)
			throws RequestParseException {
		// TODO Auto-generated method stub
		return null;
	}

	/**
	 * Needed only if app uses request types other than RequestPacket. Refer
	 * {@link NoopApp} for a more detailed example.
	 */
	@Override
	public Set<IntegerPacketType> getRequestTypes() {
		return null;
		//new HashSet<IntegerPacketType>(Arrays.asList((IntegerPacketType)PaxosPacketType.REQUEST));
	}
}
