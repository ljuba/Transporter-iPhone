// application-wide constants

extern int const kRowDividerHeight;
extern int const kButtonRowHeight;
extern int const kLineRowHeight;

typedef enum {
	kCellStatusDefault,                     // cell has results
	kCellStatusSpinner,                     // cell is seeking arrivals
	kCellStatusInternetFail,        // no internet on the device
	kCellStatusPredictionFail       // prediction error for that cell
} kCellStatus;

typedef enum {
	kWalkingLegPositionStart,                       // walking leg is the first leg in the trip
	kWalkingLegPositionMid,                         // walking leg is the middle of the trip
	kWalkingLegPositionEnd                          // walking leg is the last leg in the trip
} kWalkingLegPosition;

typedef enum {
	kTimeToTransferNoTransfer = -2,                                 // there is no tranfer to the current transit leg
	kTimeToTransferTimedTransfer = -1,                              // there is a transfer to the current leg, and it's timed (BART)
} kTimeToTransfer;
