/**
* Name: modelsgc2
* Based on the internal empty template. 
* Author: odjo
* Tags: 
*/


model modelsgc2

/* Insert your model definition here */

global torus:true 
{
	int number_of_Boat <- 20 ;
	int number_of_Radar <- 1 ;
	int number_of_Operator <- 1 ;
	int number_of_Zone <- 1 ;
	
	 
	
	
	init
	{
		create Boat number:number_of_Boat ;
		create Radar number:number_of_Radar with: (location:{50,50}) ;
		create Operator number:number_of_Operator  with: (location:{10,80}) ;
		create Zone number:number_of_Zone with: (location:{50,50})   ;
	}
}

species Zone 
{
	aspect base
	{
		draw circle(25) color: #transparent border:#black ;
	}
}

species Boat skills:[moving]
{
	bool GPS <- flip(0.5);
	rgb col <- #gray ;
    action changeColor(Boat b ,rgb c)
	{
	  b.col <- c ;
	}
	 
	reflex moving
	{
	  //Boat.speed <- 
	  do wander;
	} 
	
	aspect base {
		draw circle(2) color:col;//(is_Authorized) ?#red :#green ;
		draw string(name) color: #black font:font("Helvetica", 10 , #plain);
		//draw string(location with_precision(0)) color: # black ;
	}
}

species Radar
{
	int dectectionRange <- 20 ;
	list<Boat> CloseBoat;
	list<Boat> AllBoat ;
	
	aspect base 
	{
		draw square(4) color: #black ;
		draw string(CloseBoat) color: #brown  font:font("Helvetica", 10 , #plain);
		 
	}
	
	reflex detect 
	{
		 
		 CloseBoat <- Boat at_distance(23); 
		 
	}
	 
}

species Operator
{
	aspect base 
	{
		draw triangle(4) color: #yellow ;
		//draw string(AuthorizedBoat) color: #green font:font("Helvetica", 10 , #plain);
		draw string(UnAuthorizedBoat) color: #red font:font("Helvetica", 10 , #plain);
		//draw string(length(UnAuthorizedBoat)) color: #red font:font("Helvetica", 10 , #plain);
		 
	}
	list<Boat> AllBoat  <- Boat.population;
	list<Boat> radarBoat ;
	list<Boat> AuthorizedBoat;
	list<Boat> UnAuthorizedBoat;
	list<Boat> Authorized ;
	
	reflex work
	{
		 
		ask Radar
		{  
		
			myself.radarBoat <- CloseBoat;
		}
		
		loop i over: AllBoat
		{
			 
			if(radarBoat contains i)
			{
				if(i.GPS) 
				{
				  
				   if(!(AuthorizedBoat contains i))
				   {
				   	 AuthorizedBoat <- AuthorizedBoat + i;
				   	 write length(AuthorizedBoat);
				   }
				   ask i 
				   {
				   	 do changeColor(i,#green);
				   }
				}
				else
				{  
				   if(!(UnAuthorizedBoat contains i))
				   {
				   	UnAuthorizedBoat <- UnAuthorizedBoat + i;
				   }
				   ask i
				   {
				   	 do changeColor(i,#red);
				   }
				}//remove item:i from: AuthorizedBoat ;
			}
			else
			{
				remove item:i from: AuthorizedBoat ;
				remove item:i from: UnAuthorizedBoat ;
				ask i
				{
				  do changeColor(i,#gray);	
				} 
			}
			
		}
	}	
}
experiment experience2 type:gui 
{
	output 
	{  
		display mydisplay 
		{
			species Boat aspect:base;
			species Radar aspect:base;
			species Operator aspect:base;
			species Zone aspect:base;
		}
		display my_chart1
		{
			chart "number of AuthorizedBoat"
			{
				data"AuthorizedBoat" value:length(((Operator.population)[0]).AuthorizedBoat) ;
			}
		}
		
		display my_chart2
		{
			chart "number of UnAuthorizedBoat"
			{
				data"UnAuthorizedBoat" value:length(((Operator.population)[0]).UnAuthorizedBoat) ;
			}
		}
		
		display my_chart3
		{
			chart "number of Detected Boat By Radar"
			{
				data"Detected_Boat" value:length(((Radar.population)[0]).CloseBoat) ;
			}
		}
		
		monitor AuthorizedBoat value:length(((Operator.population)[0]).AuthorizedBoat) refresh:every(1#cycle);
		monitor UnAuthorizedBoat value:length(((Operator.population)[0]).UnAuthorizedBoat) refresh:every(1#cycle);
		monitor Boat_Detected_By_Radar value:length(((Radar.population)[0]).CloseBoat) refresh:every(1#cycle);
	}
}
