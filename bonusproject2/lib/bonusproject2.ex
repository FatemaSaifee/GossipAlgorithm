defmodule Topologies do
  use GenServer

  def main() do
    


    if (Enum.count(System.argv())!=3) do
      IO.puts "Incorrect input"
      System.halt(1)
    else

        [numNodes,topology,algorithm] = System.argv();

        {numNodes, _} = Integer.parse(numNodes);
        #  IO.puts(numNodes)

        # globalCount holds count of number of nodes who have received the message at least once
        table = :ets.new(:table, [:named_table,:public])
        :ets.insert(table, {"globalCount",0})

        # In case of rand2D and torus, we need to find the next Perfect Square value for given numNodes in the input
        if topology == "rand2D" || topology == "torus"  do
          numNodes = getNextPerfectSq(numNodes)
          allNodes = Enum.map((1..numNodes), fn(x) ->
            pid=start_node()
            updatePIDState(pid, x)
            pid
          end)

          buildTopology(topology,allNodes)
          startTime = System.monotonic_time(:millisecond)
          pickAlgorithm(algorithm, allNodes, startTime)
      else

        if topology == "3D" do
          numNodes = getNextPerfectCube(numNodes)       
          allNodes = Enum.map((1..numNodes), fn(x) ->
            pid=start_node()
            updatePIDState(pid, x)
            pid
          end)

          buildTopology(topology,allNodes)
          startTime = System.monotonic_time(:millisecond)
          pickAlgorithm(algorithm, allNodes, startTime)

        else
          allNodes = Enum.map((1..numNodes), fn(x) ->
                pid=start_node()
                updatePIDState(pid, x)
                # IO.inspect(pid)
                pid
              end)
          buildTopology(topology,allNodes)
          startTime = System.monotonic_time(:millisecond)
          pickAlgorithm(algorithm, allNodes, startTime)
        end
      end
    end
  end

  def getNextPerfectSq(numNodes) do
    round :math.pow(:math.ceil(:math.sqrt(numNodes)) ,2)
  end

  def getNextPerfectCube(numNodes) do
    round :math.pow(:math.ceil(:math.pow(numNodes,1/3)),3)
  end

  def buildFull(allNodes) do
    Enum.each(allNodes, fn(k) ->
      adjList=List.delete(allNodes,k) 
      Enum.each(allNodes, fn(x) ->
      if x!=k do
        GenServer.call(k, {:UpdateAdjacentState,x})
      end
     end)
   end)
  end


  def buildImpLine(allNodes) do
    # IO.puts "inside allnodes"

    totalNodes=Enum.count allNodes
    Enum.each(allNodes, fn(k) ->
      index=Enum.find_index(allNodes, fn(x) -> x==k end)

      cond do
        totalNodes==index+1 ->
          neighbour1=Enum.fetch!(allNodes, index - 1)
          neighbour2=List.first (allNodes)
          neighbour3=Enum.random(allNodes--[neighbour1,neighbour2,k])
          # IO.inspect([index," : ",neighbour1,neighbour2,neighbour3])
          GenServer.call(k, {:UpdateAdjacentState,neighbour1})
          GenServer.call(k, {:UpdateAdjacentState,neighbour2})
          GenServer.call(k, {:UpdateAdjacentState,neighbour3})
        true ->
          neighbour1=Enum.fetch!(allNodes, index + 1)
          neighbour2=Enum.fetch!(allNodes, index - 1)
          neighbour3=Enum.random(allNodes--[neighbour1,neighbour2,k])
          # IO.inspect([index," : ",neighbour1,neighbour2,neighbour3])
          GenServer.call(k, {:UpdateAdjacentState,neighbour1})
          GenServer.call(k, {:UpdateAdjacentState,neighbour2})
          GenServer.call(k, {:UpdateAdjacentState,neighbour3})
      end
    end)
  end


    def buildLine(allNodes) do
    # IO.puts "inside allnodes"

    totalNodes=Enum.count allNodes
    Enum.each(allNodes, fn(k) ->
      index=Enum.find_index(allNodes, fn(x) -> x==k end)

      cond do
        totalNodes==index+1 ->
          neighbour1=Enum.fetch!(allNodes, index - 1)
          neighbour2=List.first (allNodes)
          # IO.inspect([index," : ",neighbour1,neighbour2])
          GenServer.call(k, {:UpdateAdjacentState,neighbour1})
          GenServer.call(k, {:UpdateAdjacentState,neighbour2})
        true ->
          neighbour1=Enum.fetch!(allNodes, index + 1)
          neighbour2=Enum.fetch!(allNodes, index - 1)
          # IO.inspect([index," : ",neighbour1,neighbour2])
          GenServer.call(k, {:UpdateAdjacentState,neighbour1})
          GenServer.call(k, {:UpdateAdjacentState,neighbour2})
      end
    end)
    # System.halt(1)
  end


  #allNodes -> list of PIDs of all nodes in the corresponding topology
  def buildRand2D(allNodes) do
    numNodes=Enum.count allNodes
    numNodesSQR= :math.sqrt numNodes
    Enum.each(allNodes, fn(k) ->
      #count
      currentPosition=Enum.find_index(allNodes, fn(x) -> x==k end)

      #Find the bottom neighbour node a long as it exists (i.e. current position is not in last row)
      if(!isBottom(currentPosition,numNodesSQR)) do
        index=currentPosition + round(numNodesSQR)
        neighbour1=Enum.fetch!(allNodes, index)
        GenServer.call(k, {:UpdateAdjacentState,neighbour1})
      end

       #Find the top neighbour node a long as it exists (i.e. current position is not in first row)
      if(!isTop(currentPosition,numNodesSQR)) do
        index=currentPosition - round(numNodesSQR)
        neighbour2=Enum.fetch!(allNodes, index)
        GenServer.call(k, {:UpdateAdjacentState,neighbour2})
      end
       #Find the left neighbour node a long as it exists (i.e. current position is not in first column)
      if(!isLeft(currentPosition,numNodesSQR)) do
        index=currentPosition - 1
        neighbour3=Enum.fetch!(allNodes,index )
        GenServer.call(k, {:UpdateAdjacentState,neighbour3})
      end

       #Find the right neighbour node a long as it exists (i.e. current position is not in last column)
      if(!isRight(currentPosition,numNodesSQR)) do
        index=currentPosition + 1
        neighbour4=Enum.fetch!(allNodes, index)
        GenServer.call(k, {:UpdateAdjacentState,neighbour4})
      end
    end)
  end

  def build3D(allNodes) do
    numNodes=Enum.count allNodes
    numNodesSQR = :math.sqrt numNodes
    numNodesCubeRoot = :math.pow(numNodes,1/3)
    # IO.puts(numNodesCubeRoot)
    Enum.each(allNodes, fn(k) ->
      #count
      currentPosition=Enum.find_index(allNodes, fn(x) -> x==k end)

      #Find the bottom neighbour node a long as it exists (i.e. current position is not in last row)
      if(!isBottom(currentPosition,numNodesCubeRoot)) do
        index=currentPosition + round(numNodesCubeRoot)
        neighbour1=Enum.fetch!(allNodes, index)
        GenServer.call(k, {:UpdateAdjacentState,neighbour1})
      end

       #Find the top neighbour node a long as it exists (i.e. current position is not in first row)
      if(!isTop(currentPosition,numNodesCubeRoot)) do
        index=currentPosition - round(numNodesCubeRoot)
        neighbour2=Enum.fetch!(allNodes, index)
        GenServer.call(k, {:UpdateAdjacentState,neighbour2})
      end
       #Find the left neighbour node a long as it exists (i.e. current position is not in first column)
      if(!isLeft(currentPosition,numNodesCubeRoot)) do
        index=currentPosition - 1
        neighbour3=Enum.fetch!(allNodes,index )
        GenServer.call(k, {:UpdateAdjacentState,neighbour3})
      end

       #Find the right neighbour node a long as it exists (i.e. current position is not in last column)
      if(!isRight(currentPosition,numNodesCubeRoot)) do
        index=currentPosition + 1
        # IO.puts(index)
        neighbour4=Enum.fetch!(allNodes, index)
        GenServer.call(k, {:UpdateAdjacentState,neighbour4})
      end

       #Find the front neighbour node a long as it exists (i.e. current position is not in front plane)
      if(!isFront(currentPosition,numNodesCubeRoot)) do
        index=currentPosition - round(numNodesCubeRoot*numNodesCubeRoot)
        neighbour5=Enum.fetch!(allNodes, index)
        GenServer.call(k, {:UpdateAdjacentState,neighbour5})
      end

       #Find the back neighbour node a long as it exists (i.e. current position is not in back plane)
      if(!isBack(currentPosition,numNodesCubeRoot)) do
        index=currentPosition + round(numNodesCubeRoot*numNodesCubeRoot)
        neighbour6=Enum.fetch!(allNodes, index)
        GenServer.call(k, {:UpdateAdjacentState,neighbour6})
      end
    end)
  end


  def buildTorus(allNodes) do
    numNodes=Enum.count allNodes
    numNodesSQR= :math.sqrt numNodes
    Enum.each(allNodes, fn(k) ->
      currentPosition=Enum.find_index(allNodes, fn(x) -> x==k end)

      #Find the bottom neighbour node a long as it exists (i.e. current position is not in last row)
      if(!isBottom(currentPosition,numNodesSQR)) do
        index=currentPosition + round(numNodesSQR)
        neighbour1=Enum.fetch!(allNodes, index)
        GenServer.call(k, {:UpdateAdjacentState,neighbour1})
      else
        index=rem(currentPosition,round(numNodesSQR))
        neighbour1=Enum.fetch!(allNodes, index)
        GenServer.call(k, {:UpdateAdjacentState,neighbour1})
      end

       #Find the top neighbour node a long as it exists (i.e. current position is not in first row)
      if(!isTop(currentPosition,numNodesSQR)) do
        index=currentPosition - round(numNodesSQR)
        neighbour2=Enum.fetch!(allNodes, index)
        GenServer.call(k, {:UpdateAdjacentState,neighbour2})
      else
        # if node is in the top row, the upper neighbour will be the elemnt in that column in the last row
        index= numNodes - 1 - currentPosition
        neighbour2=Enum.fetch!(allNodes, index)
        GenServer.call(k, {:UpdateAdjacentState,neighbour2})
      end
       #Find the left neighbour node a long as it exists (i.e. current position is not in first column)
      if(!isLeft(currentPosition,numNodesSQR)) do
        index=currentPosition - 1
        neighbour3=Enum.fetch!(allNodes,index )
        GenServer.call(k, {:UpdateAdjacentState,neighbour3})
      else
        # if node is in the first column, the left neighbour will be the last elemnt in that row 
        index=currentPosition +  round(numNodesSQR) - 1
        neighbour3=Enum.fetch!(allNodes,index )
        GenServer.call(k, {:UpdateAdjacentState,neighbour3})
       end

       #Find the right neighbour node a long as it exists (i.e. current position is not in last column)
      if(!isRight(currentPosition,numNodesSQR)) do
        index=currentPosition + 1
        neighbour4=Enum.fetch!(allNodes, index)
        GenServer.call(k, {:UpdateAdjacentState,neighbour4})
      else
        # if node is in the first column, the left neighbour will be the last elemnt in that row 
        index=currentPosition -  round(numNodesSQR) + 1
        neighbour4=Enum.fetch!(allNodes, index)
        GenServer.call(k, {:UpdateAdjacentState,neighbour4})
      end
    end)
  end

  def handle_call({:UpdateAdjacentState,map}, _from, state) do 
    {a,b,c,d}=state
    state={a,b,c ++ [map],d}
    {:reply,a, state} 
  end 


    # Check if the current node i lies on the last row of the matrix 
  def isBottom(i,rowLen) do
    length = rowLen*rowLen
    if(i>=(length-rowLen)) do
      true
    else
      false
    end
  end

  # Check if the current node i lies on the first row of the matrix 
  def isTop(i,rowLen) do
    if(i< rowLen) do
      true
    else
      false
    end
  end

  # Check if the current node i lies on the first column of the matrix 
  def isLeft(i,colLen) do
    if(rem(i,round(colLen)) == 0) do
      true
    else
      false
    end
  end

  # Check if the current node i lies on the last column of the matrix 
  def isRight(i,colLen) do
    if(rem(i + 1,round(colLen)) == 0) do
      # IO.puts(i)
      true
    else
      false
    end
  end

    # Check if the current node i lies on the front plane of the matrix 
  def isFront(i,numNodesCubeRoot) do
    if(i<round(numNodesCubeRoot*numNodesCubeRoot)) do
      true
    else
      false
    end
  end

    # Check if the current node i lies on the back plane of the matrix 
  def isBack(i,numNodesCubeRoot) do
    length = :math.pow(numNodesCubeRoot,3)
    if(i>(length-1-round(numNodesCubeRoot*numNodesCubeRoot))) do
      true
    else
      false
    end
  end


  def pickAlgorithm(algorithm,allNodes, startTime) do
    case algorithm do
      "gossip" -> startGossip(allNodes, startTime)
      "push-sum" ->startPushSum(allNodes, startTime)
    end
  end

  def startGossip(allNodes, startTime) do
    randomFirstNode = Enum.random(allNodes)
    updateStateCount(randomFirstNode, startTime, allNodes)
    loopGossip(randomFirstNode, startTime, allNodes)
  end


  def periodicGossipTransmission(adjacentList, startTime, allNodes) do
   # spawn(Parse_Csv,:parseCsvFiles,[self])
    # IO.inspect adjacentList
    chosenRandomAdjacent=Enum.random(adjacentList)
    Task.start(Topologies,:transmitGossip,[chosenRandomAdjacent, startTime, allNodes])
    :timer.sleep 2

    periodicGossipTransmission(chosenRandomAdjacent, startTime, allNodes)
  end

  def loopGossip(chosenRandomNode, startTime, allNodes) do

    #Performing node failures for bonus
    # Division factor changes depending on number of nodes needed to be failed
    index=Enum.find_index(allNodes, fn(x) -> x==chosenRandomNode end)
    if ( rem(index, 4 ) == 0) do
      # IO.inspect chosenRandomNode
      Process.exit(chosenRandomNode, :normal)
      adjacentList = getAdjacentList(chosenRandomNode)
      chosenRandomAdjacent=Enum.random(adjacentList)
      loopGossip(chosenRandomAdjacent, startTime, allNodes)
      # raise "failed"
    
    else

      currentNodeCount = getCountState(chosenRandomNode)

      cond do
        currentNodeCount <= 10 ->

          adjacentList = getAdjacentList(chosenRandomNode)
          periodicGossipTransmission(adjacentList, startTime, allNodes)
          
        true ->
          
          Process.exit(chosenRandomNode, :normal)
          adjacentList = getAdjacentList(chosenRandomNode)
          chosenRandomAdjacent=Enum.random(adjacentList)
          loopGossip(chosenRandomAdjacent, startTime, allNodes)
          
      end
    end   
  end

  def startPushSum(allNodes, startTime) do
    randomFirstNode = Enum.random(allNodes)
    GenServer.cast(randomFirstNode, {:transmitPushSum,0,0,startTime, length(allNodes)})
  end

  
  def loopPushSum(randomNode, currentS, currentW,startTime, total_nodes) do
    GenServer.cast(randomNode, {:transmitPushSum,currentS,currentW,startTime, total_nodes})
  end
  
  def handle_cast({:transmitPushSum,receivedS,receivedW,startTime, total_nodes},state) do

    {s,pscount,adjList,w} = state  
    currentS = s + receivedS
    currentW = w + receivedW
    ratioDiff = abs((currentS/currentW) - (s/w))
    if(ratioDiff<:math.pow(10,-10)) do
      if pscount<2 do
        pscount = pscount + 1
        randomNode = Enum.random(adjList)
        loopPushSum(randomNode, currentS/2, currentW/2,startTime, total_nodes)
        state = {currentS/2,pscount,adjList,currentW/2}
        {:noreply,state}
      else
        count = :ets.update_counter(:table, "globalCount", {2,1})
        if count == total_nodes do
          endTime = System.monotonic_time(:millisecond) - startTime
          IO.puts "Convergence time for push-sum for #{count} nodes was achieved in " <> Integer.to_string(endTime) <>" Milliseconds"
          :timer.sleep(100)
          System.halt(1)
          {:noreply,state}
        else
          randomNode = Enum.random(adjList)
          loopPushSum(randomNode, currentS/2, currentW/2,startTime, total_nodes)
          state = {currentS/2,pscount,adjList,currentW/2}
          {:noreply,state}
        end
      end
    else
      pscount = 0
      randomNode = Enum.random(adjList)
      loopPushSum(randomNode, currentS/2, currentW/2,startTime, total_nodes)
      state = {currentS/2,pscount,adjList,currentW/2}
      {:noreply,state}
    end


  end

  def transmitGossip(pid, startTime, allNodes) do
    #Data store count update
    updateStateCount(pid, startTime, allNodes)
    loopGossip(pid, startTime, allNodes)
  end

  def getAdjacentList(pid) do
    GenServer.call(pid,{:GetAdjacentList})
  end

  def handle_call({:GetAdjacentList}, _from ,state) do
    {a,b,c,d}=state
    {:reply,c, state}
  end

  def handle_call({:GetState}, _from ,state) do
    {a,b,c,d}=state
    # IO.inspect("b #{b}")
    {:reply,state, state}
    
  end

  def getState(pid) do
    GenServer.call(pid,{:GetState})
  end

  def getCountState(pid) do
    GenServer.call(pid,{:GetCountState})
  end

  def handle_call({:GetCountState}, _from ,state) do
    {a,b,c,d}=state
    {:reply,b, state}
    
  end

  def updateStateCount(pid, startTime, allNodes) do

    GenServer.call(pid, {:UpdateCountState,startTime, allNodes})

  end
 
  def handle_call({:UpdateCountState,startTime, allNodes}, _from,state) do
  {a,b,c,d}=state
    if(b==0) do
        totalCount = :ets.update_counter(:table, "globalCount", {2,1})
        
        #Performing node failures for bonus
        # Addition factor changes depending on number of nodes needed to be failed
        if(totalCount+100 == length(allNodes)) do
        endTime = System.monotonic_time(:millisecond) - startTime
        IO.puts "Convergence for gossip for #{totalCount} nodes was achieved in #{endTime} Milliseconds"
         :timer.sleep(1)
         System.halt(1)
        end
    end
  state={a,b+1,c,d}
  {:reply, b+1, state}
  end


  def buildTopology(topology,allNodes) do
    case topology do
      "full" ->buildFull(allNodes)
      "rand2D" ->buildRand2D(allNodes)
      "line" ->buildLine(allNodes)
      "impLine" ->buildImpLine(allNodes)
      "torus" -> buildTorus(allNodes)
      "3D" -> build3D(allNodes)
    end
  end

  def updatePIDState(pid,nodeID) do
    GenServer.call(pid, {:UpdatePIDState,nodeID})
  end

  def handle_call({:UpdatePIDState,nodeID}, _from ,state) do
    {a,b,c,d} = state
    state={nodeID,b,c,d}
    {:reply,a, state}
  end

  def updatePSCount(pid,pscount) do
    GenServer.call(pid, {:UpdatePSCount,pscount})
  end

  def handle_call({:UpdatePSCount,pscount}, _from ,state) do
    {a,b,c,d} = state
    state={a,pscount,c,d}
    {:reply,b, state}
  end



  def init(:ok) do
    {:ok, {0,0,[],1}} #{s,pscount,adjList,w} , {nodeId,count,adjList,w}
  end

  def start_node() do
    {:ok,pid}=GenServer.start_link(__MODULE__, :ok,[])
    pid
  end


  def waitIndefinitely() do
    waitIndefinitely()
  end

end


Topologies.main()
Topologies.waitIndefinitely()