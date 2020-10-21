class Synprops:
    def __init__(self, dEsyn, delta_bistable, delta_oscillatory):
        # Define the universal synaptic reversal potential.
        self.dEsyn = dEsyn             # [V] Synapse Reversal Potential.

        # Define the bistable and oscillatory delta values.
        self.delta_bistable = delta_bistable
        self.delta_oscillatory = delta_oscillatory
