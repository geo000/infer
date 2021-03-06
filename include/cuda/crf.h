#ifndef INFER_CUDA_CRF_H
#define INFER_CUDA_CRF_H

#include <vector>

namespace infer {
namespace cuda {

/**
 * A conditional random field initalised on GPU memory
 */
class crf {
public:
    enum type {
        ARRAY, L1, SMALL_ARRAY
    };

    float *dev_unary_;
    const unsigned width_, height_, labels_;
    const type type_;

    const float lambda_;
    const float trunc_;
    float *dev_pairwise_;

    explicit crf(const unsigned width, const unsigned height, const unsigned labels, const std::vector<float> unary, const float lambda, const unsigned trunc);
    explicit crf(const unsigned width, const unsigned height, const unsigned labels, const std::vector<float> unary, const float lambda, const bool small, const std::vector<float> pairwise);

    explicit crf(const crf &prev, int);
    ~crf();

private:
    // disable copy and copy assign
    crf(const crf &);
    crf &operator=(const crf &);

};

}
}

#endif // INFER_CUDA_CRF_H
