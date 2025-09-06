-- CreateEnum
CREATE TYPE "public"."TransactionType" AS ENUM ('INCOME', 'EXPENSE');

-- CreateEnum
CREATE TYPE "public"."PaymentType" AS ENUM ('BANK_TRANSFER', 'CASH', 'DEBIT_CARD', 'CREDIT_CARD');

-- CreateEnum
CREATE TYPE "public"."CardProviderType" AS ENUM ('VISA', 'MASTER');

-- CreateEnum
CREATE TYPE "public"."CardType" AS ENUM ('DEBIT', 'CREDIT');

-- CreateEnum
CREATE TYPE "public"."CardLifeStatus" AS ENUM ('ACTIVE', 'STOLEN', 'DISABLED', 'EXPIRED');

-- CreateEnum
CREATE TYPE "public"."CreditType" AS ENUM ('CARD', 'INSTALLMENT', 'BANK_LOAN', 'LOCAL_LOAN', 'LEASE');

-- CreateEnum
CREATE TYPE "public"."CreditPaymentStatus" AS ENUM ('CREATED', 'PENDING', 'PAID', 'CANCELLED');

-- CreateEnum
CREATE TYPE "public"."UserRole" AS ENUM ('USER', 'ADMIN');

-- CreateEnum
CREATE TYPE "public"."CreditStatus" AS ENUM ('ONGOING', 'DELETED', 'PAID', 'CANCELLED');

-- CreateTable
CREATE TABLE "public"."users" (
    "user_id" SERIAL NOT NULL,
    "email" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "password" TEXT NOT NULL,
    "image" TEXT,
    "phone_number" TEXT,
    "role" "public"."UserRole" NOT NULL DEFAULT 'USER',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "is_deleted" BOOLEAN NOT NULL DEFAULT false,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "users_pkey" PRIMARY KEY ("user_id")
);

-- CreateTable
CREATE TABLE "public"."transactions" (
    "transaction_id" SERIAL NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT,
    "type" "public"."TransactionType" NOT NULL,
    "payment_type" "public"."PaymentType" NOT NULL,
    "occurred_at" TIMESTAMP(3) NOT NULL,
    "to" TEXT,
    "from" TEXT,
    "amount" DECIMAL(65,30) NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "user_id" INTEGER NOT NULL,
    "is_deleted" BOOLEAN NOT NULL DEFAULT false,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "transactions_pkey" PRIMARY KEY ("transaction_id")
);

-- CreateTable
CREATE TABLE "public"."cards" (
    "card_id" SERIAL NOT NULL,
    "display_name" TEXT NOT NULL,
    "issuer_bank" TEXT NOT NULL,
    "network" "public"."CardProviderType" NOT NULL,
    "last4" TEXT NOT NULL,
    "type" "public"."CardType" NOT NULL,
    "status" "public"."CardLifeStatus" NOT NULL,
    "credit_limit" DECIMAL(65,30),
    "exp_month" INTEGER NOT NULL,
    "exp_year" INTEGER NOT NULL,
    "userId" INTEGER NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "is_deleted" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "cards_pkey" PRIMARY KEY ("card_id")
);

-- CreateTable
CREATE TABLE "public"."card_statements" (
    "statement_id" SERIAL NOT NULL,
    "cardId" INTEGER NOT NULL,
    "transactionId" INTEGER NOT NULL,
    "amount" DECIMAL(65,30) NOT NULL,
    "vendor" TEXT NOT NULL,

    CONSTRAINT "card_statements_pkey" PRIMARY KEY ("statement_id")
);

-- CreateTable
CREATE TABLE "public"."credits" (
    "credit_id" SERIAL NOT NULL,
    "transactionId" INTEGER,
    "credit_type" "public"."CreditType" NOT NULL,
    "interest_rate" DECIMAL(7,4),
    "status" "public"."CreditStatus" NOT NULL,
    "principal_amount" DECIMAL(65,30) NOT NULL,
    "total_amount" DECIMAL(20,8) NOT NULL,
    "remaining_amount" DECIMAL(20,8),
    "due_date" TIMESTAMP(3),
    "total_payable_months" INTEGER,
    "no_of_months_paid" INTEGER,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "userId" INTEGER NOT NULL,

    CONSTRAINT "credits_pkey" PRIMARY KEY ("credit_id")
);

-- CreateTable
CREATE TABLE "public"."credit_payments" (
    "credit_payment_id" SERIAL NOT NULL,
    "creditId" INTEGER NOT NULL,
    "status" "public"."CreditPaymentStatus" NOT NULL,
    "due_date" TIMESTAMP(3) NOT NULL,
    "paid_at" TIMESTAMP(3),
    "transactionId" INTEGER,
    "due_amount" DECIMAL(65,30) NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "credit_payments_pkey" PRIMARY KEY ("credit_payment_id")
);

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "public"."users"("email");

-- CreateIndex
CREATE INDEX "transactions_user_id_occurred_at_idx" ON "public"."transactions"("user_id", "occurred_at");

-- CreateIndex
CREATE UNIQUE INDEX "cards_last4_key" ON "public"."cards"("last4");

-- CreateIndex
CREATE INDEX "cards_card_id_userId_idx" ON "public"."cards"("card_id", "userId");

-- CreateIndex
CREATE UNIQUE INDEX "cards_userId_last4_network_type_key" ON "public"."cards"("userId", "last4", "network", "type");

-- CreateIndex
CREATE INDEX "card_statements_cardId_transactionId_idx" ON "public"."card_statements"("cardId", "transactionId");

-- CreateIndex
CREATE INDEX "credits_due_date_idx" ON "public"."credits"("due_date");

-- CreateIndex
CREATE INDEX "credit_payments_creditId_due_date_idx" ON "public"."credit_payments"("creditId", "due_date");

-- AddForeignKey
ALTER TABLE "public"."transactions" ADD CONSTRAINT "transactions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("user_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."cards" ADD CONSTRAINT "cards_userId_fkey" FOREIGN KEY ("userId") REFERENCES "public"."users"("user_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."card_statements" ADD CONSTRAINT "card_statements_cardId_fkey" FOREIGN KEY ("cardId") REFERENCES "public"."cards"("card_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."card_statements" ADD CONSTRAINT "card_statements_transactionId_fkey" FOREIGN KEY ("transactionId") REFERENCES "public"."transactions"("transaction_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."credits" ADD CONSTRAINT "credits_transactionId_fkey" FOREIGN KEY ("transactionId") REFERENCES "public"."transactions"("transaction_id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."credits" ADD CONSTRAINT "credits_userId_fkey" FOREIGN KEY ("userId") REFERENCES "public"."users"("user_id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."credit_payments" ADD CONSTRAINT "credit_payments_creditId_fkey" FOREIGN KEY ("creditId") REFERENCES "public"."credits"("credit_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."credit_payments" ADD CONSTRAINT "credit_payments_transactionId_fkey" FOREIGN KEY ("transactionId") REFERENCES "public"."transactions"("transaction_id") ON DELETE SET NULL ON UPDATE CASCADE;
