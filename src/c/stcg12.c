/*
MIT License

Copyright (c) [Subham Swastik Pradhan] [2025]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

/**************************************************************************************************************************************
 *
 *   EDUCATIONAL
 *
 *   Shiksha O Anusandhan,
 *   Institute of Technical Education and Research
 *
 *   stcg12.c
 *
 *   Subham Swatik Pradhan
 *   01-05-2025
 *
 *   Statistical Calculator
 *      v1.0.1.0
 *   Operations:
 *      - Arithmetic Mean
 *      - Median
 *      - Mode
 *      - Max
 *      - Min
 *      - Population standard deviation
 *      - Population variance
 *
 *
 ***************************************************************************************************************************************/

//===============================

#include <limits.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
//===============================

// #define DEBUG

#define INV_2 0.5f

inline float STC_sqr(float val) { return val * val; }

inline void STC_swap(int* first, int* second)
{
    if ((*first) == (*second))
    {
        return;
    }

    int temp = *first;
    *first = *second;
    *second = temp;
}

inline int STC_min(int first, int second)
{
    if (first > second)
    {
        return second;
    }
    return first;
}

inline int STC_max(int first, int second)
{
    if (first < second)
    {
        return second;
    }
    return first;
}

// TODO: try making it iterative
void STC_quicksort(int* data, ptrdiff_t start, ptrdiff_t end)
{
    if (end < start || start < 0 || end < 0)
    {
        (void)fprintf_s(stderr, "ERROR: invalid input! \n");
        return;
    }

    if (start == end)
    {
        return;  // one element
    }

    ptrdiff_t i_idx = start - 1;
    ptrdiff_t j_idx = i_idx + 1;
    ptrdiff_t pivot = end;  // pivot must always be the end
    int pivot_val = data[pivot];

    for (; j_idx < pivot; j_idx++)
    {
        if (data[j_idx] < pivot_val)
        {
            i_idx++;
            STC_swap(&data[j_idx], &data[i_idx]);
        }
    }
    if (j_idx == pivot)  // reached pivot
    {
        i_idx++;
        STC_swap(&data[i_idx], &data[pivot]);
        pivot = i_idx;
    }

    if (pivot > start)
    {
        STC_quicksort(data, start, pivot - 1);
    }
    if (pivot < end)
    {
        STC_quicksort(data, pivot + 1, end);
    }
}

void STC_printArray(int* data, size_t num, const char* prepend)
{
    (void)printf_s("%s\n", prepend);
    for (size_t i = 0; i < num; i++)
    {
        (void)printf_s("%d", data[i]);
        if (i < (num - 1))
        {
            (void)printf_s(", ");
        }
    }
    (void)printf_s("\n");
}

//============================================================================================================================

/// @brief Arithmetic mean: (x1+x2...xn)/n
/// @param data integer array
/// @param num size of array
/// @return Arithemtic mean
inline float STC_computeMean(const int* data, size_t num)
{
    int sum = 0;
    for (int i = 0; i < num; i++)
    {
        sum += data[i];
    }
    return (float)sum / (float)num;
}

/// @brief NOTE: Data must be sorted!
///
/// Arithmetic Median:
/// If num is odd, the median is the element at index (num - 1) / 2.
///
/// If num is even, the median is the average of the elements at indices num / 2
/// - 1 and num / 2.
///
/// @param data
/// @param num
/// @return Median
inline float STC_computeMedian(const int* data, size_t num)
{
    if (num % 2 == 1)
    {
        size_t median_idx = (num - 1) / 2;
        return (float)data[median_idx];
    }

    size_t median_idx = num / 2;
    return (float)(data[median_idx] + data[median_idx - 1]) * INV_2;
}

/// @brief NOTE: Data must be sorted!
/// @param data
/// @param num
/// @return mode (xi with max frequency)
int STC_computeMode(const int* data, size_t num)
{
    int mode = 0;
    int mode_reps = 0;

    int last = INT_MIN;  // TODO:buggy
    int reps = 0;

    for (size_t i = 0; i < num; i++)
    {
        int curr = data[i];
        if (curr == last)  // if repeat
        {
            reps++;
        }
        else  // sequence break
        {
            reps = 1;
        }
        if (reps > mode_reps)  // mode condition
        {
            mode = curr;
            mode_reps = reps;
        }
        last = curr;
    }
    return mode;
}

int STC_min_array(int* data, size_t num)
{
    int min = INT_MAX;
    for (size_t i = 0; i < num; i++)
    {
        min = STC_min(min, data[i]);
    }
    return min;
}

int STC_max_array(int* data, size_t num)
{
    int max = INT_MIN;
    for (size_t i = 0; i < num; i++)
    {
        max = STC_max(max, data[i]);
    }
    return max;
}

float STC_computePopulationStandardDeviation(int* data, size_t num)
{
    float mu_ = STC_computeMean(data, num);
    float numerator = 0;
    for (size_t i = 0; i < num; i++)
    {
        numerator += STC_sqr((float)data[i] - mu_);
    }
    return sqrtf(numerator / (float)num);
}

float STC_computePopulationVariance(int* data, size_t num)
{
    /*
    float E_x2 = 0;
    for (size_t i = 0; i < num; i++)
    {
        E_x2 += STC_sqr(data[i]);
    }
    E_x2 /= num;
    float Ex_2 = STC_sqr(STC_computeMean(data, num));
    return E_x2 - Ex_2;
    */
    return STC_sqr(STC_computePopulationStandardDeviation(data, num));
}

/// @brief entrypoint
/// @param argc
/// @param argv
/// @return
int main(int argc, char** argv)
{
    (void)printf_s("[Statistical Calculator v1.0.1.0]\nworking directory: %s\n",
                   argv[0], argc);

SMPLC_INP:
    printf_s("Enter sample size (INT):\n");
    size_t sample_size = 0;
    {
        int res = scanf_s("%d", &sample_size);
        if (!res || sample_size <= 0 || res > 1)
        {
            (void)fprintf_s(stderr, "invalid input\n");
            goto SMPLC_INP;
        }
    }

    int* sample_data_buffer = malloc(sample_size * sizeof(int));
    if (sample_data_buffer == NULL)  // exception
    {
        (void)fprintf_s(stderr, "ERR: Allocation failure");
        exit(EXIT_FAILURE);
    }
    {
    VALUE_INPUT:
        printf_s("Requesting sample values:\n");

        for (int i = 0; i < sample_size; i++)
        {
            (void)printf_s("Enter value for sample %d/%d (INT): ", i + 1,
                           sample_size);
            int val = 0;
            {
                int res = scanf_s("%d", &val);
                if (!res)
                {
                    (void)fprintf_s(stderr, "Bad Value Input\n");
                    goto VALUE_INPUT;
                }
            }
            sample_data_buffer[i] = val;
        }
        (void)printf_s(
            "Sample values set "
            "\n[==============================================================]"
            "\n");
#ifdef DEBUG
        STC_printArray(sample_data_buffer, sample_size, "Array:");
#endif
        STC_quicksort(sample_data_buffer, 0, (ptrdiff_t)sample_size - 1);
#ifdef DEBUG
        (void)printf_s("sorted samples\n");
        STC_printArray(sample_data_buffer, sample_size, "Samples");
#endif
        (void)printf_s("Count: %d\n", sample_size);
        (void)printf_s("Arithmetic Mean: %.3f\n",
                       STC_computeMean(sample_data_buffer, sample_size));
        (void)printf_s("Arithmetic Median: %.3f\n",
                       STC_computeMedian(sample_data_buffer, sample_size));
        (void)printf_s("Mode: %d\n",
                       STC_computeMode(sample_data_buffer, sample_size));
        (void)printf_s("Max: %d\n",
                       STC_max_array(sample_data_buffer, sample_size));
        (void)printf_s("Min: %d\n",
                       STC_min_array(sample_data_buffer, sample_size));
        (void)printf_s("Standard Deviation(rho): %.3f\n",
                       STC_computePopulationStandardDeviation(
                           sample_data_buffer, sample_size));
        (void)printf_s(
            "Variance: %.3f\n",
            STC_computePopulationVariance(sample_data_buffer, sample_size));
    }
    (void)printf_s("[PROGRAM END]");
    free(sample_data_buffer);
    sample_data_buffer = NULL;

    return EXIT_SUCCESS;
}
