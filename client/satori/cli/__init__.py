
import click
from satori.lib.wallet import verify as satori_verify
from satori.lib import wallet
from satori.lib.wallet import connection

@click.group()
def main():
    '''Satori CLI'''

@main.command()
def help():
    '''open this file to modify'''
    print('used to verify a signed message')

@main.command()
@click.argument('message', type=str, required=True)
@click.argument('signature', type=str, required=True)
@click.argument('pubkey', type=str, required=True)
def verify(message: str, signature:str, pubkey:str):
    '''verifies a message and signature and public key'''
    print(satori_verify(
        message=message,
        signature=signature,
        publicKey=pubkey
    ))

@main.command()
@click.argument('message', type=str, required=True)
@click.argument('signature', type=str, required=True)
@click.argument('address', type=str, required=True)
def verify_by_address(message: str, signature:str, address:str):
    '''verifies a message and signature and address'''
    print(satori_verify(
        message=message,
        signature=signature,
        address=address
    ))
    
@main.command()
def create_wallet_auth_payload():
    '''uses existing saved wallet to sign a message for authentication'''
    w = wallet.Wallet(temporary=True)
    w.init()
    print(connection.payloadForServer(w))
    
@main.command()
def create_test_wallet_auth_payload():
    '''generates a new wallet and signs a message for authentication'''
    w = wallet.Wallet(temporary=True)
    w.generate()
    print(connection.payloadForServer(w))
        