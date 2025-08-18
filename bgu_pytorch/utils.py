import os
import cupy as np

class Walker:
    def __init__(self, limits, params, device, rank):
        self.rank = rank
        self.device = device
        self.limits = limits
        self.params = params
        self.num_spins = params.num_spins
        self.prop_size = params.prop_size
        self.h = np.zeros(self.num_spins)
        self.log_g = np.zeros(self.num_spins)
        self.log_f = params.initial_log_f
        self.it = 0
        self.update_its = 0
        self.need_initialization = True
        self.reject_out = 0
        self.random_accept = 0

    def step(self):
        self.js = np.random.choice(self.num_spins, size=self.prop_size, replace=False)
        log_MH = float(np.random.rand() - 0.5)
        if log_MH >= 0 or np.random.rand() < np.exp(log_MH):
            self.h[self.js] += 1
            self.random_accept += 1
        else:
            self.reject_out += 1
        self.it += 1
        self.update_its += 1
        self.need_initialization = False

    def save(self):
        samples_filename = f"samples_rank{self.rank}.npz"
        np.savez(samples_filename,
                 h=self.h.get(),
                 log_g=self.log_g.get(),
                 log_f=self.log_f,
                 it=self.it,
                 update_its=self.update_its)

    def load(self):
        samples_filename = f"samples_rank{self.rank}.npz"
        res = np.load(samples_filename, allow_pickle=True)
        self.h = np.array(res['h'])
        self.log_g = np.array(res['log_g'])
        self.log_f = res['log_f'].item()
        self.it = res['it'].item()
        self.update_its = res['update_its'].item()
        self.need_initialization = False


def exchange(walker, paired_rank):
    # Dummy exchange function to be customized for your simulation logic
    print(f"Exchanging between rank {walker.rank} and {paired_rank}")