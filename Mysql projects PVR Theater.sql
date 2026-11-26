-- Created database for PVR_theater:
create database PVR_Theater;

Use PVR_Theater;

-- Creating tables:

CREATE TABLE Theater (TheaterID     INT    PRIMARY KEY,
    Name         VARCHAR(100)   NOT NULL,
    TicketType    VARCHAR(20)    NOT NULL,
    Rate          DECIMAL(8,2)   NOT NULL,
    MaxCapacity   INT            NOT NULL,
    BalCapacity   INT            NOT NULL
);

CREATE TABLE Bookings (
    BookingID    INT             AUTO_INCREMENT PRIMARY KEY,
    TheaterID    INT             NOT NULL,
    TrxDate      DATETIME        DEFAULT NOW(),
    TicketType   VARCHAR(20)     NOT NULL,
    Qty          INT             NOT NULL,
    Rate         DECIMAL(8,2)    NOT NULL,
    Amount       DECIMAL(10,2)   NOT NULL,
    FOREIGN KEY (TheaterID) REFERENCES Theater(TheaterID)
);

CREATE TABLE TicketCancellation (
    CancelID     INT             AUTO_INCREMENT PRIMARY KEY,
    BookingID    INT             NOT NULL,
    TheaterID    INT             NOT NULL,
    Cancel_Date  Datetime default current_timestamp,
    TicketType   VARCHAR(20)     NOT NULL,
    Cancel_Qty   INT             NOT NULL,
    Rate         DECIMAL (8,2)   NOT NULL,
    Amount       DECIMAL(10,2)   NOT NULL,
    FOREIGN KEY (BookingID) REFERENCES Bookings(BookingID)
);

-- Inserting records into theater table:

INSERT INTO Theater (TheaterID, Name, TicketType, Rate, MaxCapacity, BalCapacity)
VALUES
    (1, 'Grand Cinemas',   'Gold',     350.00, 100, 100),
    (2, 'Grand Cinemas',   'Silver',   200.00, 150, 150),
    (3, 'Starlight Plex',  'Platinum', 500.00,  60,  60),
    (4, 'Starlight Plex',  'Gold',     350.00,  80,  80),
    (5, 'Metro Movies',    'Silver',   180.00, 200, 200),
    (6, 'Metro Movies',    'Gold',     300.00, 120, 120);
    
-- Stored Procedure 'SP_BookTicket' for booking tickets:
    
Delimiter //
Create Procedure SP_BookTicket(
	IN p_TheaterID int,
    IN p_TicketType varchar(20),
    IN p_Qty int,
    OUT p_Message varchar(100)
)
Begin
    Declare v_TicketType Varchar(20);
    Declare v_BalCap int;
    Declare v_Rate decimal(8,2);
    Declare v_Amount decimal(10,2);
    declare v_Error_msg Varchar(100);

Declare exit handler for sqlexception    
Begin
        Rollback;
    select 'Transaction failed' as result;
        Resignal;
End;

Start Transaction;

    Select BalCapacity, Rate, TicketType
    Into v_BalCap, v_Rate, v_TicketType
    From Theater
    Where TheaterID = p_TheaterID
    For update;

    If p_TicketType <> v_TicketType then
        Signal SQLState '45000'
        Set Message_text = 'Your requested ticket(s) did not match the available tickets at the selected theater';
	
    Elseif p_Qty <= 0 Then
	    Signal SQLState '45000'
		Set message_text = 'Please enter a valid quantity. Quantity must be greater than 0 ';

    Elseif p_Qty > v_BalCap Then
		Set v_Error_Msg = Concat(
            'Insufficient capacity. requested: ', p_Qty , 
            ' , only ', v_BalCap , ' ticket(s) Available. '
        );

        Signal SQLstate '45000'
		Set message_text = v_Error_msg;

    Else
		Set v_Amount = p_Qty * v_Rate;

	Insert into Bookings
            (TheaterID, TrxDate, TicketType, Qty, Rate, Amount)
        Values
            (p_TheaterID, NOW(), p_TicketType, p_Qty, v_Rate, v_Amount);

	if last_insert_id() = 0 then 
        signal sqlstate '45000'
        set message_text = 'Insert failed ';
	end if;
        
	update Theater
        set BalCapacity = BalCapacity - p_Qty
		Where TheaterID = p_TheaterID;
		
    if Row_count() = 0 then
        signal sqlstate '45000'
        set message_text = 'Update failed';
	end if;

        set p_Message = Concat(
            'Booking confirmed: ', p_Qty, ' ticket(s) * Rs. ', v_Rate , ' = Rs ' , v_Amount
        );
        
    End if;
    Commit;
End //

Delimiter ;

-- Stored Procedure 'sp_TicketCancellation' for ticket cancellation:

Delimiter //
create procedure sp_TicketCancellation (
    IN p_BookingID INT,
    IN p_Cancelqty INT,
    OUT p_message Varchar(100)
)

BEGIN

    Declare v_BookingID INT;
    Declare v_TheaterID INT;
    Declare v_TicketType Varchar(20);
    Declare v_BookedQty INT ;
    Declare v_Rate Decimal(8,2);
    Declare v_Amount Decimal(10,2);
    Declare v_msg  Varchar(100);

Declare exit handler for sqlexception 
Begin 
        Rollback;
select 'Ticket cancellation failed' as result;
        Resignal;
End;

Start Transaction;

    select BookingID, TheaterID, TicketType, Qty, Rate
    into v_BookingID, v_TheaterID, v_TicketType, v_BookedQty, v_rate
	from Bookings
	where bookingID = p_BookingID
    for Update;

    If v_BookingID is null then
       Signal SQLState '45000'
	   Set Message_text = 'Invalid Booking ID';

    Elseif p_Cancelqty <= 0 Then
       Signal SQLState '45000'
       Set Message_text = 'Invalid quantity. Quantity must be grater than 0';

	Elseif p_Cancelqty > v_BookedQty Then
	   Set v_msg = Concat('Cancellation quantity', p_Cancelqty, 
           'exceeds booked tickets', v_BookedQty);
       Signal SQLState '45000'
       Set Message_text = v_msg;

    Else 
       set v_Amount = p_Cancelqty * v_Rate;

   Insert into TicketCancellation( BookingID, TheaterID, Cancel_Date, TicketType, Cancel_Qty, Rate, Amount)
   Values( p_BookingID, v_TheaterID, Now(), v_TicketType, p_Cancelqty, v_Rate, v_Amount);

    If last_insert_id() = 0 Then
		Signal SQLState '45000'
		Set Message_text = 'Insert failed';
	End if;

    update Theater 
        Set BalCapacity = BalCapacity + p_Cancelqty
		Where TheaterID = v_TheaterID
        AND TicketType = v_TicketType ;

    If Row_Count() = 0 Then
	    Signal SQLState '45000'
		Set Message_text = 'Theater update failed';
    End if;

    Update Bookings 
        Set Qty = Qty - p_Cancelqty,
		Amount = Amount - v_Amount
		Where BookingID = p_BookingID;

    If Row_Count() = 0 Then
       Signal SQLState '45000'
	   Set message_text = 'Bookings update failed';
    end if;
       
    Commit;

        Set p_Message = Concat('Cancel Successful. Refund Rs:', v_amount,
        'for cancel quantity', p_Cancelqty);
	end if;
end //

Delimiter ;

-- calling the procedure (sp_BookTicket):
call sp_BookTicket(1, 'Gold',6,@msg);

-- select @message (i.e out parameter p_message)
select @msg as result;

-- calling the procedure (sp_TicketCancellation):
call sp_TicketCancellation(1,1,@msg);

-- select @msg(out paramter p_message)
select @msg as result;
