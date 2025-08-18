from dataclasses import dataclass

@dataclass
class Params:
    n_train: int
    n_test: int
    bins_e: int
    bins_q: int
    num_spins: int
    prop_size: int
    initial_log_f: float

n_train = 300
n_test = 10000
bins_q = 1000
bins_e = n_train + 1

params = Params(
    n_train=n_train,
    n_test=n_test,
    bins_e=bins_e,
    bins_q=bins_q,
    num_spins=100,
    prop_size=5,
    initial_log_f=1.0
)

range_bins_q = 100
qw = 4
L = int((range_bins_q * 2) / (qw + 1))

eq_limits = {}
for w in range(qw):
    eq_limits[w] = {
        'q_min': 700 + int(w * L / 2),
        'q_max': 700 + int(w * L / 2 + L - 1),
        'e_min': n_train - 5,
        'e_max': n_train
    }

paired_ranks_for_exchange = {
    0: {},
    1: {}
}

for i in range(0, qw, 2):
    paired_ranks_for_exchange[0][i] = i + 1
    paired_ranks_for_exchange[0][i + 1] = i

paired_ranks_for_exchange[1][0] = -1
for i in range(1, qw - 2, 2):
    paired_ranks_for_exchange[1][i] = i + 1
    paired_ranks_for_exchange[1][i + 1] = i
paired_ranks_for_exchange[1][qw - 1] = -1
