#include "cuda/crf.h"
#include "cuda/util.h"
#include "cuda/core.h"

#include <cuda.h>
#include <stdexcept>
#include <iostream>

namespace infer {
namespace cuda {

crf::crf(const unsigned width, const unsigned height, const unsigned labels, const std::vector<float> unary, const float lambda, const unsigned trunc)
    : width_(width)
    , height_(height)
    , labels_(labels)
    , dev_unary_(0)
    , lambda_(lambda)
    , type_(L1)
    , trunc_(trunc)
    , dev_pairwise_(0) {

    cuda_check(cudaMalloc(&dev_unary_, width * height * labels * sizeof(float)));
    cuda_check(cudaMemcpy(dev_unary_, &unary[0], width * height * labels * sizeof(float), cudaMemcpyHostToDevice));
}

crf::crf(const unsigned width, const unsigned height, const unsigned labels, const std::vector<float> unary, const float lambda, const bool small, const std::vector<float> pairwise)
    : width_(width)
    , height_(height)
    , labels_(labels)
    , dev_unary_(0)
    , lambda_(lambda)
    , type_(small ? SMALL_ARRAY : ARRAY)
    , trunc_(0)
    , dev_pairwise_(0) {

    cuda_check(cudaMalloc(&dev_unary_, width * height * labels * sizeof(float)));
    cuda_check(cudaMemcpy(dev_unary_, &unary[0], width * height * labels * sizeof(float), cudaMemcpyHostToDevice));

    const unsigned pair_sizes = small ? labels * labels : width * height * labels * labels * 2;
    cuda_check(cudaMalloc(&dev_pairwise_, pair_sizes * sizeof(float)));
    cuda_check(cudaMemcpy(dev_pairwise_, &pairwise[0], pair_sizes * sizeof(float), cudaMemcpyHostToDevice));
}
 
crf::crf(const crf &prev, int)
    : width_((prev.width_ + 1) / 2)
    , height_((prev.height_ + 1) / 2)
    , labels_(prev.labels_)
    , dev_unary_(0)
    , lambda_(prev.lambda_)
    , type_(prev.type_)
    , trunc_(prev.trunc_)
    , dev_pairwise_(0) {

    if (prev.type_ == ARRAY) {
        throw std::runtime_error("Cannot generate a scaled down version of a CRF with explicit pairwise potential are specified");
    }

    const unsigned size = width_ * height_ * labels_;
    cuda_check(cudaMalloc(&dev_unary_, size * sizeof(float)));

    if (prev.type_ == SMALL_ARRAY || prev.type_ == ARRAY) {
        const unsigned pair_sizes = prev.type_ == SMALL_ARRAY ? labels_ * labels_ : width_ * height_ * labels_ * labels_ * 2;
        cuda_check(cudaMalloc(&dev_pairwise_, pair_sizes * sizeof(float)));
        cuda_check(cudaMemcpy(dev_pairwise_, prev.dev_pairwise_, pair_sizes * sizeof(float), cudaMemcpyDeviceToDevice));
    }

    // initalise the new potential from the previous one
    dim3 block(16, 16);
    dim3 grid((width_ + block.x - 1) / block.x, (height_ + block.y - 1) / block.y);

    fill_next_layer_pot<<<grid, block>>>(labels_, width_, height_, prev.width_, prev.height_, prev.dev_unary_, dev_unary_);
    cuda_check(cudaGetLastError());

}

crf::~crf() {
    cudaFree(dev_unary_);

    if (dev_pairwise_) {
        cudaFree(dev_pairwise_);
    }
}

}
}
