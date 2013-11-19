#ifndef INFER_CRF_H
#define INFER_CRF_H

#include "util.h"

#include <vector>

namespace infer {

/**
 * Immutable class representing a grid conditional markov random field
 */
class crf {

public:
    /**
     * The type of the pairwise term of this CRF
     */
    enum class type {
        ARRAY, L1, L2
    };

    const unsigned width_, height_, labels_;
    const type type_;

    const std::vector<float> unary_;

    const float lambda_;
    const float trunc_;

    const std::vector<float> pairwise_;

private:
    const indexer idx_;
    const indexer ndx_;
    const edge_indexer edx_;

public:
    /**
     * Initalise the grid CRF with a linear or quadratic potential
     *
     * @param width width of the CRF grid
     * @param height height of the CRF grid
     * @param labels number of labels in the CRF
     * @param potentials a width x height x label array of unary potentials
     * @param lambda scaling of the pairwise potentials
     * @param norm 1 or 2
     * @param trunc constant used to truncate the norm
     */
   explicit crf(const unsigned width, const unsigned height, const unsigned labels, const std::vector<float> unary, const float lambda, const unsigned norm, const unsigned truc);

    /**
     * Initalise the grid CRF with an array of width x height x 2 x labels x labels pairwise terms
     *
     * @param width width of the CRF grid
     * @param height height of the CRF grid
     * @param labels number of labels in the CRF
     * @param potentials a width x height x label array of unary potentials
     * @param lambda scaling of the pairwise potentials
     * @param potentials a width x height x label x label array of potentials
     */
    explicit crf(const unsigned width, const unsigned height, const unsigned labels, const std::vector<float> unary, const float lambda, const std::vector<float> pairwise);

    /**
     * Gets the unary potential given the node's coordinates and label
     */
    float unary(const unsigned x, const unsigned y, const unsigned label) const;

    /**
     * Gets the whole vector of unary potential for that node
     */
    const float *unary(const unsigned x, const unsigned y) const;

    /**
     * Gets the pairwise potential for two nodes given their labels, lambda is applied to the result
     */
    float pairwise(const unsigned x, const unsigned y, const unsigned l1, const move dir, const unsigned l2) const;

    /**
     * Gets the unary energy of this labeling
     */
    float unary_energy(const std::vector<unsigned> labeling) const;

    /**
     * Gets the pairwise energy of this labeling
     */
    float pairwise_energy(const std::vector<unsigned> labeling) const;

    /**
     * Generate a condensed CRF with half the width and height
     */
    crf downsize() const;

    /**
     * Default move constructor
     */
    crf(crf &&) = default;

private:
    crf(const crf &) = delete;
    crf &operator=(const crf &) = delete;
};

}

#endif // INFER_CRF_H
