USE Sesion2;

-- Kịch bản rủi ro:
-- Ví không có hoặc âm tiền
-- Giao dịch không hợp lệ (rỗng / sai loại)
-- Giao dịch trùng / replay attack
-- Số tiền âm hoặc = 0Số tiền âm hoặc = 0

CREATE TABLE wallets (
    wallet_id INT PRIMARY KEY AUTO_INCREMENT,

    user_id INT NOT NULL UNIQUE,

    balance DECIMAL(15,2) NOT NULL DEFAULT 0,

    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',

    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_wallet_balance CHECK (balance >= 0),

    CONSTRAINT chk_wallet_status CHECK (status IN ('ACTIVE', 'LOCKED'))
);

CREATE TABLE transactions (
    transaction_id BIGINT PRIMARY KEY AUTO_INCREMENT,

    wallet_id INT NOT NULL,

    type VARCHAR(20) NOT NULL,

    amount DECIMAL(15,2) NOT NULL,

    status VARCHAR(20) NOT NULL DEFAULT 'SUCCESS',

    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    reference_code VARCHAR(50) NOT NULL UNIQUE,

    CONSTRAINT fk_wallet
        FOREIGN KEY (wallet_id)
        REFERENCES wallets(wallet_id),

    CONSTRAINT chk_transaction_amount CHECK (amount > 0),

    CONSTRAINT chk_transaction_type CHECK (
        type IN ('DEPOSIT', 'WITHDRAW', 'PAYMENT')
    ),

    CONSTRAINT chk_transaction_status CHECK (
        status IN ('SUCCESS', 'FAILED', 'PENDING')
    )
);
