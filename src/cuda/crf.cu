#include "cuda/crf.h"
#include "cuda/util.h"

#include <cuda.h>

namespace infer {
namespace cuda {

crf::crf(const unsigned width, const unsigned height, const unsigned labels, const std::vector<float> unary, const float lambda, const unsigned norm, const unsigned trunc)
    : width_(width)
    , height_(height)
    , labels_(labels)
    , dev_unary_(0)
    , lambda_(lambda)
    , type_(norm == 1 ? L1 : L2)
    , trunc_(trunc)
    , dev_pairwise_(0) {

    cuda_check(cudaMalloc(&dev_unary_, width * height * labels));
}

crf::crf(const unsigned width, const unsigned height, const unsigned labels, const std::vector<float> unary, const float lambda, const std::vector<float> pairwise)
    : width_(width)
    , height_(height)
    , labels_(labels)
    , dev_unary_(0)
    , lambda_(lambda)
    , type_(ARRAY)
    , trunc_(0)
    , dev_pairwise_(0) {

    cuda_check(cudaMalloc(&dev_unary_, width * height * labels));
    cuda_check(cudaMalloc(&dev_pairwise_, labels * labels));
}

crf::~crf() {
    cudaFree(dev_unary_);

    if (dev_pairwise_) {
        cudaFree(dev_pairwise_);
    }
}

}
}
