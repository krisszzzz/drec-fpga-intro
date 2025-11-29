#include <cstdio>
#include <vector>

using ElemT = short;

class sa_state {
private:
  sa_state() {};

public:
  static sa_state &get_instance() {
    static sa_state g_state{};
    return g_state;
  }

  int sa_size = 0;
  std::vector<ElemT> A = {};
  std::vector<ElemT> B = {};
  std::vector<ElemT> C = {};

  static void set_sa_size(int size) {
    auto &instance = get_instance();
    instance.sa_size = size;
    instance.A.reserve(size * size);
    instance.B.reserve(size * size);
    instance.C.reserve(size * size);
  }

  static void set_A_element(ElemT elem, int offset) {
    get_instance().A[offset] = elem;
  }

  static void set_B_element(ElemT elem, int offset) {
    get_instance().B[offset] = elem;
  }

  static void set_C_element(ElemT elem, int offset) {
    get_instance().C[offset] = elem;
  }

  // A = row-major
  // B = col-major (transposed)
  static std::vector<ElemT> gemm_tn_ref() {
    std::printf("matmul_ref\n");
    auto &instance = get_instance();

    std::vector<ElemT> C_ref(instance.sa_size * instance.sa_size);
    int sa_size = instance.sa_size;

    for (int i = 0; i < sa_size; i++) {
      for (int j = 0; j < sa_size; j++) {
        C_ref[i * sa_size + j] = 0;

        for (int k = 0; k < sa_size; k++) {
          C_ref[i * sa_size + j] +=
              instance.A[i * sa_size + k] * instance.B[j * sa_size + k];
        }
      }
    }

    return C_ref;
  }

  static bool verify() {
    auto &instance = get_instance();
    auto C_ref = gemm_tn_ref();
    int sa_size = instance.sa_size;
    bool passed = true;

    for (int i = 0; i < sa_size; i++) {
      for (int j = 0; j < sa_size; j++) {
        ElemT ref_val = C_ref[i * sa_size + j];
        ElemT c_val = instance.C[i * sa_size + j];

        if (ref_val != c_val) {
          std::printf("(%d %d) %d != %d\n", i, j, ref_val, c_val);
          passed = false;
        }

        if (ref_val == c_val) {
          std::printf("(%d %d) %d == %d\n", i, j, ref_val, c_val);
        }
      }
    }

    return passed;
  }
};

extern "C" void set_sa_size(int size) {
    sa_state::set_sa_size(size);
}

extern "C" void set_A_element(ElemT elem, int offset) {
  sa_state::set_A_element(elem, offset);
}

extern "C" void set_B_element(ElemT elem, int offset) {
  sa_state::set_B_element(elem, offset);
}

extern "C" void set_C_element(ElemT elem, int offset) {
  sa_state::set_C_element(elem, offset);
}

extern "C" bool verify() {
    return sa_state::verify();
}