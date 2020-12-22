class Synprops:
    def __init__(self, gmax, Esyn, Ehi, Elo):
        self.gmax = gmax        # [S] Synapse maximum conductance
        self.Esyn = Esyn            # [V] Synapse Reversal Potential.
        self.Ehi = Ehi          # [V] Synapse votlage limit
        self.Elo = Elo          # [V] Synapse votlage threshold
        self.R = Ehi - Elo      # [V] Synapse voltage range
