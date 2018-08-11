package  
{
	/**
	 * ...
	 * @author Nicholas 'A' Feinberg
	 */
	public class UnlockRequirement
	{
		public var hasParents:Boolean;
		public var parents:Array;
		public var unlockThreshold:int;
		
		public function UnlockRequirement(hasParents:Boolean, parents:String = null, threshold:int = -1) 
		{
			this.hasParents = hasParents
			if (hasParents) {
				this.parents = parents.split(',');
				/*this.parents = new Array();
				var parentNames:Array = parents.split(',')
				trace(parents, parentNames);
				for (var i:int = 0; i < parentNames.length; i++)
					this.parents[i] = *///Manufactoria.levelsByName[parentNames[i]];
			} else
				this.unlockThreshold = threshold;
		}
		
		public function unlocked():Boolean {
			if (!hasParents)
				return Manufactoria.totalUnlocked >= unlockThreshold;
			
			for (var i:int = 0; i < parents.length; i++)
				if (Manufactoria.unlocked[Manufactoria.levelsByName[parents[i]]] != Manufactoria.BEATEN)
					return false;
			
			return true;
		}
	}

}